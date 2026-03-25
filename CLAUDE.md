# CLAUDE.md — Piano Learner

## Project Overview

A Rails 8.1 app that helps beginners learn piano through AI-generated song guides, MIDI keyboard practice, and progress tracking. The AI layer calls the Claude API (`claude-sonnet-4-6`) to produce structured study content (overview, song map, hand positioning, difficult sections, harmony) for each song.

**Stack:** Ruby on Rails 8.1 · SQLite · Solid Queue / Cable / Cache · Hotwire (Turbo + Stimulus) · Importmap · Vitest · RSpec · Claude API (Anthropic)

---

## Key Architecture

### Models & Associations

```
Song
  ├─ has_one  :song_analysis      (AI-generated content + structured MIDI data)
  ├─ has_many :song_parts         (left/right/both hand note data)
  └─ has_many :practice_sessions
       └─ has_many :session_attempts
```

### Services

| Path | Responsibility |
|---|---|
| `app/services/ai/song_overview_generator.rb` | Calls Claude API, parses JSON, updates `SongAnalysis` |
| `app/services/analyzers/` | Chord detection, difficulty scoring, hand separation, orchestration |

### Jobs

| Job | Trigger | Behaviour |
|---|---|---|
| `SongOverviewJob` | `songs#analyze` (if not yet generated) | Runs AI generator in background, broadcasts Turbo Stream to `#ai_overview` on completion or failure |

### AI Status Flow

`ai_status: nil` (fresh) → controller sets `"pending"` → job runs →
- **Success:** `ai_status: nil`, all `ai_*` fields populated
- **Failure:** `ai_status: "failed"`, error banner shown via Turbo Stream

### Frontend

- Stimulus controllers: `keyboard`, `midi`, `practice`, `progress_chart`
- Turbo Streams for live AI analysis updates and session completion
- MIDI Web API integration for real keyboard input

---

## Routes Summary

```
GET  /                              → songs#index
GET  /songs/:id                     → songs#show
GET  /songs/:id/analyze             → songs#analyze  (triggers AI job)
GET  /dashboard                     → dashboard#index
GET  /midi_setup                    → midi_setup#show
GET  /practice_sessions             → practice_sessions#index
POST /song_parts/:id/practice_sessions           → practice_sessions#create
GET  /song_parts/:id/practice_sessions/:id       → practice_sessions#show
PATCH /practice_sessions/:id/complete            → practice_sessions#complete
POST /song_parts/:id/practice_sessions/:id/attempts → attempts#create (JSON API)
```

---

## Environment

Copy `.env.example` to `.env` and set:

```
ANTHROPIC_API_KEY=your_key_here
```

`dotenv-rails` loads this automatically in development and test.

---

## Running the App

```bash
bin/rails db:migrate
bin/rails server         # http://localhost:3000
```

---

## Testing

### Ruby (RSpec)

```bash
bundle exec rspec                        # all specs
bundle exec rspec spec/models/           # models only
bundle exec rspec spec/requests/         # controller/integration
bundle exec rspec spec/services/         # services and jobs
bundle exec rspec spec/jobs/             # jobs only
```

Factories live in `spec/factories/`. Use `:with_analysis` trait on `Song` to get a song with a `SongAnalysis` record.

### JavaScript (Vitest)

```bash
npm test           # run once
npm run test:watch # watch mode
```

Tests live in `test/javascript/`. Stimulus and Chart.js are mocked in `test/javascript/support/`.

---

## Workflow Rules

### Committing

**Always ask the user before creating a git commit.** Never commit autonomously, even after completing a task.

### Building a New Feature

When implementing a new feature, follow this sequence before considering the work done:

1. **Write the code** following existing patterns (services for business logic, jobs for async work, Stimulus for frontend interaction).
2. **Run all Ruby tests:** `bundle exec rspec` — all specs must pass.
3. **Run all JavaScript tests:** `npm test` — all tests must pass.
4. **Test in Chrome via Chrome DevTools MCP:** navigate to the relevant page(s) and visually verify the feature works end-to-end. Take screenshots to confirm behaviour.
5. **Ask the user before committing.**

### Chrome DevTools MCP — Existing Instance Error

If a Chrome MCP tool call fails with _"The browser is already running"_ or _"already running for ... chrome-profile"_:

1. Kill all existing Chrome and chrome-devtools-mcp processes:
   ```bash
   pkill -f chrome-devtools-mcp; pkill -f chrome
   sleep 1
   ```
2. Retry the tool call — the MCP server will launch a fresh browser automatically.

---

## Code Conventions

- **Acronym inflection:** `AI` is registered as an acronym in `config/initializers/inflections.rb`. Migration and class names must use `AI` (uppercase), e.g. `AddAIStatusToSongAnalyses`.
- **Background jobs:** use `perform_later`, never call generators synchronously from controllers.
- **Turbo Streams:** broadcast from jobs, not controllers.
- **JSON API endpoints** (e.g. `AttemptsController`): skip CSRF with `protect_from_forgery with: :null_session`, respond only with JSON.
- **Song difficulty:** stored as integer 1–5. Songs with `import_status: "ready"` are shown in the library.
- **Test coverage:** every controller, model, service, and job must have RSpec tests covering success, failure, and edge cases.
