# Session 0 — Nano Banana Prompt Validation Gate

**Status:** Not started
**Blocker for:** All subsequent sessions
**Budget:** ~30 minutes wall time, ~$2 in API costs
**Files touched:** `hairlens-worker/scripts/validate.sh`, `test-selfies/`, `prompt-results/`, `prompt-results/SCORES.md`

## Goal

Confirm that **Gemini 2.5 Flash Image (Nano Banana) can transform hair on real selfies while preserving identity at decision-grade realism**. If it cannot, Hair Lens - AI does not exist. This is a true go/no-go gate.

## Success Criteria

Across **10 canonical test selfies × 5 style descriptions = 50 generations**:

- ✅ **≥ 90%** of outputs show recognizable, unchanged facial identity (eyes, nose, mouth, jawline match input)
- ✅ **≥ 80%** show photorealistic hair (no wig overlay, no plastic look, hairline blends naturally)
- ✅ **≥ 90%** preserve background and lighting

**Fail-state:**
- If identity preservation < 90% on first run: iterate `buildHairPrompt()` and rerun
- If 3 prompt iterations still don't hit 90%: **STOP. Product is not viable. Pivot or abandon.**

This is the hardest, most important test in the project. Do it honestly. Score yourself strictly.

## Test Inputs

### 10 Selfies

Collect or shoot 10 front-facing selfies covering:

| # | Subject | Notes |
|---|---------|-------|
| 1 | South Asian man, short hair, clean shaven | Baseline |
| 2 | South Asian man, short hair, beard | Facial hair preservation |
| 3 | East Asian man, short hair | Baseline |
| 4 | Caucasian man, medium hair | Length-decrease test |
| 5 | Man with glasses | Accessory preservation |
| 6 | South Asian woman, long hair | Length-decrease test |
| 7 | East Asian woman, shoulder-length | Baseline |
| 8 | Caucasian woman, short hair | Length-increase test |
| 9 | Woman with bangs | Existing-feature replacement |
| 10 | Mixed lighting / slightly off-angle | Robustness test |

All shot on iPhone, front-facing, neutral background, even lighting. No sunglasses, no hats.

### 5 Style Prompts

1. `men_french_crop_fade` → "a modern French crop with a low skin fade on the sides and short textured fringe on top, styled with a matte finish"
2. `men_indian_groom_slick` → "a classic slicked-back groom's hairstyle suitable under a safa or pagdi, with shine and clean side parting"
3. `women_curtain_bangs` → "shoulder-length layered cut with soft curtain bangs framing the face, natural texture and gentle waves"
4. `women_indian_wedding_updo` → "an elegant low bun updo for an Indian bride, with side-swept front section and subtle volume"
5. **Custom freeform** → "long wavy beach-blonde hair flowing down to mid-back, slight ocean breeze movement"

## Steps

1. Create `~/dev/mane-worker/test-selfies/` and add the 10 input photos as `01.jpg` … `10.jpg`
2. Write `scripts/validate.sh` — bash loop calling Gemini REST API for each (selfie, prompt) pair
3. Output to `prompt-results/<selfie>_<style>.jpg`
4. Manually score each of the 50 outputs against the 3 criteria → `prompt-results/SCORES.md`
5. Tally percentages
6. If criteria met → green-light Session 1. If not → iterate prompt, rerun.

## Reference: curl call

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [
        { "text": "<full prompt from buildHairPrompt()>" },
        { "inline_data": { "mime_type": "image/jpeg", "data": "<base64 selfie>" } }
      ]
    }],
    "generationConfig": { "responseModalities": ["IMAGE"] }
  }' \
  | jq -r '.candidates[0].content.parts[] | select(.inline_data) | .inline_data.data' \
  | base64 --decode > output.jpg
```

## Out of Scope

- iOS code (zero)
- Cloudflare Worker code (zero — call Gemini directly via curl)
- StoreKit, paywall, UI
- Style catalog beyond the 5 test prompts

## Scoring Template (`SCORES.md`)

```
| Selfie | Style | Identity (Y/N) | Realism (Y/N) | Background (Y/N) | Notes |
|--------|-------|----------------|---------------|------------------|-------|
| 01.jpg | french_crop_fade |  |  |  |  |
| 01.jpg | indian_groom_slick |  |  |  |  |
| ... | ... |  |  |  |  |

Totals: Identity __/50 (__%) | Realism __/50 (__%) | Background __/50 (__%)
Verdict: PASS / FAIL
Next: [Session 1 / iterate prompt / abandon]
```

## When Done

Update `CLAUDE.md` Session Status with:
- Date
- Result: PASS / FAIL with percentages
- If PASS: link to `SCORES.md`, mark Session 1 unblocked
- If FAIL: document what failed, prompt iteration plan or pivot decision

Commit + push.
