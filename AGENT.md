# HairLens — Claude Code Agent Instructions

## How to Start Every Session

Paste this at the start of EVERY Claude Code session:

```
You are working on Hair Lens - AI — iOS app for AI hairstyle preview via Gemini 2.5 Flash Image (Nano Banana).

Read CLAUDE.md AND AGENT.md before doing ANYTHING.

You are a senior iOS/Swift engineer + backend engineer (Cloudflare Workers).
Write production-quality code. No placeholders. No TODOs. Finish what you start.

The 12 rules below are non-negotiable. Bias: caution over speed on non-trivial work.
```

---

## The 12 Non-Negotiable Rules

These apply to every task unless explicitly overridden by the user in writing.

**Rule 1 — Think Before Coding.** State assumptions explicitly. Ask rather than guess. Push back when a simpler approach exists. Stop when confused. If a task requires inference beyond the spec, surface the inference before acting on it.

**Rule 2 — Simplicity First.** Minimum code that solves the problem. Nothing speculative. No abstractions for single-use code. No "future-proofing" — YAGNI applies even to your own helpers.

**Rule 3 — Surgical Changes.** Touch only what you must. Don't improve adjacent code. Match existing style. Don't refactor what isn't broken. If you find a bug outside scope, surface it — don't fix it silently.

**Rule 4 — Goal-Driven Execution.** Every task starts with explicit success criteria. Loop until verified. Strong success criteria let you loop independently without checking in. If criteria are vague, ask before starting.

**Rule 5 — Use Gemini Only for Judgment Calls.** Use the model for: image editing, style descriptions, content moderation. Do NOT use for: routing, retries, deterministic transforms, validation, anything code can answer. If code can answer, code answers. Saves money and is more reliable.

**Rule 6 — Token Budgets Are Not Advisory.** Per-task: 4,000 tokens. Per-session: 30,000 tokens. If approaching budget, summarize state and start fresh. Surface the breach loudly. Do not silently overrun. Long contexts degrade output quality — a fresh session with a tight prompt beats a bloated one.

**Rule 7 — Surface Conflicts, Don't Average Them.** If two patterns in the codebase contradict, pick one (more recent / more tested) and explain why. Flag the other for cleanup. Never silently invent a third hybrid.

**Rule 8 — Read Before You Write.** Before adding code, read the file you're editing, its exports, its immediate callers, and any shared utilities. If unsure why existing code is structured a certain way, ask. There is almost always a reason.

**Rule 9 — Tests Verify Intent, Not Just Behavior.** Tests must encode WHY behavior matters, not just WHAT it does. A test that can't fail when business logic changes is wrong. Prefer 3 tests with sharp intent over 30 that lock current output verbatim.

**Rule 10 — Checkpoint After Every Significant Step.** Summarize what was done, what's verified, what's left. Don't continue from a state you can't describe back. If you can't summarize, you're confused — stop.

**Rule 11 — Match the Codebase's Conventions, Even If You Disagree.** Conformance > taste inside this codebase. If a convention is harmful, surface it as a discussion. Don't fork silently. The cost of inconsistency exceeds the benefit of being right.

**Rule 12 — Fail Loud.** "Completed" is wrong if anything was skipped silently. "Tests pass" is wrong if any were skipped. Default to surfacing uncertainty, not hiding it. Better to over-report than under-report.

---

## Token-Saving Rules

```
❌ NEVER  "Build the whole app"
✅ ALWAYS "Build ONLY [one view/service]. Nothing else."

❌ NEVER  re-explain the app each session
✅ ALWAYS "Read CLAUDE.md" — it has everything

❌ NEVER  let Claude rewrite already-correct files
✅ ALWAYS specify the exact file path to edit

❌ NEVER  use one long thread for multiple features
✅ Start a fresh session per feature

❌ NEVER  paste large files into the prompt
✅ Reference by path; Claude Code reads them

❌ NEVER  ask Claude to "explore" or "look around"
✅ Tell Claude what file to read first

❌ NEVER  ask Claude to write multiple variations
✅ Specify the one design; iterate only if it fails
```

---

## Session Template

```
Read CLAUDE.md and AGENT.md.

TODAY'S TASK:
[ONE thing — e.g.]
Implement Services/FaceValidator.swift.
- Vision framework
- Single-face check, area >= 8%, no extreme yaw/pitch (>25°)
- Return .valid or .invalid(reason: String)
- Edit only Services/FaceValidator.swift

SUCCESS CRITERIA:
- Builds clean (no warnings)
- Returns .valid for test/good_selfie.jpg
- Returns .invalid with correct reason for: multi_face.jpg, blurry.jpg, profile.jpg

Do not touch any other files.
When done, update Session Status in CLAUDE.md, commit, push.
```

---

## Recommended Session Order

| # | Task | Files | Blocker for |
|---|------|-------|-------------|
| **0** | **GO/NO-GO**: validate Nano Banana prompt via curl on 10 selfies | Worker repo only | Everything |
| 1 | Xcode project scaffold: targets, bundle ID, SwiftData container, app icon | HairLensApp.swift, AppState.swift | All iOS |
| 2 | FaceValidator service + tests | FaceValidator.swift | 6 |
| 3 | ImageProcessor service + tests | ImageProcessor.swift | 6 |
| 4 | Style catalog JSON (30 entries) + loader | StyleCatalog.json, StyleCatalog.swift | 7 |
| 5 | Cloudflare Worker scaffold + Gemini call (no credit gate yet) | hairlens-worker repo | 6 |
| 6 | APIClient + minimal generate flow (hardcoded "free mode") | APIClient.swift | 8 |
| 7 | StylePickerView + InputView (UI, wired to APIClient) | StylePickerView.swift, InputView.swift | 8 |
| 8 | GeneratingView + ResultView with before/after slider | ResultView.swift, BeforeAfterSlider.swift | 9 |
| 9 | HistoryStore + HistoryView (SwiftData) | HistoryStore.swift, HistoryView.swift | — |
| 10 | StoreKit 2 products + CreditManager | CreditManager.swift, PaywallView.swift | 11 |
| 11 | Worker: receipt validation + credit ledger | credits.ts | 13 |
| 12 | Settings, restore purchase, terms/privacy | SettingsView.swift | 14 |
| 13 | Onboarding + first-run free credits | OnboardingView.swift | 14 |
| 14 | App Store screenshots + metadata | Assets, Info.plist | 15 |
| 15 | TestFlight build + beta agreement | — | Launch |

**Critical:** Sessions 1+ are blocked on Session 0 passing. If Nano Banana can't preserve identity reliably, the product doesn't exist. See `SESSION_00_VALIDATION.md`.

---

## Critical "Don't Break" Rules

```
❌ NEVER call Gemini directly from iOS
✅ Always route through Cloudflare Worker (API key protection)

❌ NEVER ship the Gemini API key in the app bundle
✅ Worker holds the key in environment secrets

❌ NEVER store StoreKit shared secret in the app
✅ Worker validates receipts server-side

❌ NEVER upload raw camera output
✅ Always ImageProcessor.prepare() first — 1024px JPEG q=0.8

❌ NEVER call API without FaceValidator passing
✅ FaceValidator first — saves $0.04 per bad image

❌ NEVER rewrite the prompt template without re-running the 10-selfie test
✅ buildHairPrompt() is the moat — change requires regression test

❌ NEVER use third-party Swift packages
✅ Apple frameworks only (same rule as your other apps)

❌ NEVER persist images outside SwiftData on the device
✅ One source of truth: HistoryStore @Model
```

---

## Debugging Cheat Sheet

| Symptom | Likely Cause | Where to Look |
|---------|--------------|---------------|
| Generated face doesn't match user | Prompt template lost identity clause | Worker `prompts.ts` |
| Hair looks like a filter/wig overlay | Style description too generic | `STYLE_LIBRARY` entries |
| API returns 400 from Gemini | Image too large or wrong format | ImageProcessor — confirm <4MB JPEG |
| API returns 429 | Worker rate limit | Worker KV rate limit logic |
| Credits not deducting | Receipt validation failing | Worker `credits.ts`, App Store shared secret |
| Free credits not granted | First-run flag missing | `CreditManager.grantFirstRunCredits()` |
| App rejected for hardcoded secret | Worker URL contains key, or key in code | `APIClient.swift` — only public Worker URL allowed |
| Slow generation (>15s) | Worker cold start or Gemini region | Cloudflare logs |
| Safety block from Gemini | Prompt or input flagged | Worker should surface specific code → app shows actionable copy |
| Crash on photo pick | Image too large for Vision | ImageProcessor before Validator |

---

## Output Format

- Show full file path above every code block
- Write complete files, not partial edits
- End every session with: **what was built, files changed, next step**
- Update Session Status in CLAUDE.md before declaring done
- `git commit` + `git push` before declaring done
