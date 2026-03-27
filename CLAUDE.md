# CLAUDE.md — Piano Learner

## Project Overview

A Rails 8.1 app that helps beginners learn piano through AI-generated song guides, MIDI keyboard practice, and progress tracking. The AI layer calls the Claude API (`claude-sonnet-4-6`) to produce structured study content (overview, song map, hand positioning, difficult sections, harmony) for each song.

**Stack:** Ruby on Rails 8.1 · SQLite · Solid Queue / Cable / Cache · Hotwire (Turbo + Stimulus) · Importmap · VexFlow 5.0 · Chart.js 4 · Vitest · RSpec · Claude API (Anthropic)

---

## Features

### Song Library (`/songs`)
Grid of all songs with `import_status: "ready"`. Each card shows title, composer, difficulty badge (1–5), BPM, key signature, time signature, and links to Practice and Analysis.

### Song Detail (`/songs/:id`)
Header with title/composer, info cards (BPM, Key, Time Signature), detected chord progression, and a list of practice parts (name, hand, note count) each with a "Start Practice" button.

### AI Song Analysis (`/songs/:id/analyze`)
Five AI-generated sections (overview, song map, hand positions, difficult sections, harmony) plus structured data panels (chord grid, difficulty sections, dynamics map, hand separation). Turbo Stream updates in real time when AI generation completes. Regenerate button re-triggers the job.

### Practice Mode (`/song_parts/:id/practice_sessions/:id`)
BPM-based auto-advance practice with:

- **Count-in**: 1-measure countdown ("1, 2, 3, 4") at song BPM before music starts
- **Staff notation**: VexFlow renders 3 measures at a time with treble clef and bar lines. A red vertical playhead line sweeps across at BPM speed. Staff auto-scrolls to the next page of 3 measures when the playhead crosses the boundary. Notes not yet reached render dark (#333); correct notes turn green (#4CAF50); missed or incorrect notes turn red (#f44336)
- **Virtual keyboard**: 61 keys (C2–C7) with octave labels. Flashes green on correct play, red on wrong note
- **MIDI input**: WebMIDI bridge captures note-on/off events from connected MIDI keyboards
- **Timing engine**: `requestAnimationFrame` loop tracks `performance.now()` elapsed time. Each note has a beat window `[beat, beat + dur)`. Playing the correct MIDI note inside the window scores "correct"; wrong MIDI scores "incorrect"; window passing with no input scores "missed"
- **Restart**: Resets counters, clears staff colors/playhead, removes Session Complete card, restarts count-in
- **Completion**: Auto-completes when playhead passes the last note. Sends `correct_notes`, `incorrect_notes`, `notes_reached` to server. Server runs `SessionScorer` and renders a Turbo Stream completion card with composite score breakdown

### Scoring System
Each completed session is scored across three dimensions:

| Dimension | Weight | Calculation |
|---|---|---|
| **Accuracy** | 50% | `correct / (correct + incorrect) × 100` |
| **Timing** | 25% | Consistency of response times (median absolute deviation from median) |
| **Dynamics** | 25% | Average per-note velocity deviation from expected (0–127 scale) |

Composite score = weighted sum. If velocity data is unavailable, its 25% is redistributed equally to accuracy and timing. Timing/velocity scores only use correct note attempts.

### Practice History (`/practice_sessions`)
Table of all sessions showing song, part, date, notes reached, accuracy %, composite score, and completion status. Color-coded: green ≥80%, yellow ≥50%, red <50%.

### Dashboard (`/dashboard`)
Summary metrics (total sessions, average accuracy, average composite, unique songs), Chart.js line graph of accuracy over time, and 5 most recent sessions table.

### MIDI Setup (`/midi_setup`)
Live device connection status, device list, last note played display with velocity bar. Troubleshooting tips.

---

## Key Architecture

### Models & Associations

```
Song
  ├─ has_one  :song_analysis      (AI-generated content + structured data)
  ├─ has_many :song_parts         (left/right/both hand note data)
  └─ has_many :practice_sessions
       └─ has_many :session_attempts
```

### Note Data Structure

Each note in `song_parts.notes_data` (JSON array):
```json
{ "pos": 0, "midi": 60, "name": "C4", "dur": 1.0, "vel": 80, "beat": 0.0 }
```
- `pos`: sequential index (0-based)
- `midi`: MIDI note number (0–127, middle C = 60)
- `name`: note name with octave (e.g., "C#4")
- `dur`: duration in beats (1.0 = quarter, 2.0 = half, 0.5 = eighth)
- `vel`: velocity (0–127)
- `beat`: absolute beat position in song timeline

### Song Fields
`title`, `composer`, `tempo_bpm` (integer), `time_signature` (string, e.g. "4/4"), `key_signature`, `difficulty` (1–5), `import_status` ("ready" shown in library)

### Stimulus Controllers

| Controller | Responsibility |
|---|---|
| `practice_controller` | BPM timing engine, count-in, auto-advance, note evaluation, scoring, session completion |
| `staff_controller` | VexFlow staff rendering (3 measures), playhead animation, note result coloring |
| `keyboard_controller` | 61-key virtual piano (C2–C7), green/red flash feedback |
| `midi_controller` | WebMIDI bridge, dispatches `midi:noteon` / `midi:noteoff` events |
| `progress_chart_controller` | Chart.js accuracy-over-time line chart on dashboard |

### Services

| Path | Responsibility |
|---|---|
| `app/services/ai/song_overview_generator.rb` | Calls Claude API, parses JSON, updates `SongAnalysis` |
| `app/services/scoring/session_scorer.rb` | Computes timing, velocity, and composite scores from session attempts |
| `app/services/analyzers/` | Chord detection, difficulty scoring, hand separation, orchestration |

### Jobs

| Job | Trigger | Behaviour |
|---|---|---|
| `SongOverviewJob` | `songs#analyze` (if not yet generated) | Runs AI generator in background, broadcasts Turbo Stream to `#ai_overview` on completion or failure |

### Practice Flow

1. User clicks "Start Practice" on a song part → creates `PracticeSession`, redirects to practice view
2. Click "Start Practice" button → count-in (1 measure at song BPM)
3. After count-in → `requestAnimationFrame` loop begins, playhead sweeps staff
4. For each note: MIDI input evaluated against timing window → `SessionAttempt` recorded via fire-and-forget POST
5. Missed notes (no input during window) auto-recorded as incorrect
6. After last note duration → PATCH `/complete` with final counts → server scores via `SessionScorer` → Turbo Stream renders completion card
7. "Restart" resets all state, clears staff, starts fresh count-in on same session

### External Libraries

| Library | CDN | Purpose |
|---|---|---|
| VexFlow 5.0.0 | `esm.sh/vexflow@5.0.0` | Staff notation rendering (SVG) |
| Chart.js 4 | `cdn.jsdelivr.net/npm/chart.js@4` | Dashboard accuracy chart |

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

Tests live in `test/javascript/`. Stimulus, Chart.js, and VexFlow are mocked in `test/javascript/support/`.

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

---

## UI Theme

- **Background:** #111 / #1a1a2e (dark)
- **Text:** #e0e0ff / #b0b0dd (light purple)
- **Accent:** #7c7cff / #5555ff (purple)
- **Success:** #90ee90 / #4CAF50 (green)
- **Error:** #ee9090 / #f44336 (red)
- **Staff background:** white with black notation
- **Playhead:** #ff4444 (red, 2px)
- **Keyboard:** white keys on #111 background, black keys #222
