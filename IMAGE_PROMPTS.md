# Hair Lens — Image Generation Prompts

All prompts are for Google Gemini image generation.
Generated images go into: `ManeLens/Assets.xcassets/`

---

## How to Use This File with Gemini

1. Copy one prompt at a time into Gemini (gemini.google.com → image generation)
2. Generate the image
3. Download/save it with the exact filename shown (e.g. `sample_buzz_cut_3.png`)
4. Drag the saved image into Xcode → Assets.xcassets → into the matching `.imageset` folder
5. Mark the row ✅ in the status table below
6. Tell Claude "added _3/_4/_5 for buzz_cut" and Claude will update `HairStyle.swift`

**Tips for Gemini:**
- If the result looks like a filter/illustration, add: *"unedited DSLR photograph, photorealistic, no CGI"*
- If the face is cut off, add: *"full head visible, shoulders in frame"*
- If background is wrong, add: *"clean studio background, no props"*
- For back-view prompts: add *"no face visible, head and shoulders from behind"* if Gemini tries to show a face

---

## Naming Convention

| Suffix | Angle | Purpose |
|--------|-------|---------|
| `_1` | Front 3/4 face angle | Primary card thumbnail |
| `_2` | Front direct / slight variation | Carousel image 2 |
| `_3` | Back view | Shows cut shape from behind |
| `_4` | Right side profile | Shows fade/length profile |
| `_5` | Left 3/4 angle | Shows texture + face framing |

---

## Status Tracker

Update this table as images are generated. ✅ = done, ⏳ = pending.

| Style | `_1` | `_2` | `_3` | `_4` | `_5` |
|-------|------|------|------|------|------|
| `sample_indian_groom_slick` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_wolf_cut` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_indian_wedding_updo` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_french_crop_fade` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_beach_blonde_waves` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_curtain_bangs` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_buzz_cut` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_classic_pompadour` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_man_bun` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_disconnected_undercut` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_textured_quiff` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_classic_bob` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_pixie_cut` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_long_straight` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_side_swept_bangs` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_braided_bridal_updo` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_reception_waves` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_platinum_blonde` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_balayage_highlights` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |
| `sample_ivy_league` | ✅ | ✅ | ⏳ | ⏳ | ⏳ |

**Progress: 40 / 100 images complete**

---

## BATCH 2 — Multi-angle prompts (_3 back · _4 side · _5 three-quarter)

> All prompts follow the format:
> *Photorealistic professional portrait photograph, studio lighting, neutral background. [Subject]. [Hair]. [Angle]. High detail, sharp focus, magazine quality.*

---

### 1. Classic Groom (`sample_indian_groom_slick`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, neutral warm background. South Asian male in white wedding sherwani. Hair slicked back with pomade, perfectly smooth and structured, tapered sides. Back view, no face visible, showing the full nape and back of head. High detail, sharp focus, magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, neutral warm background. South Asian male in white wedding sherwani. Hair slicked back with pomade, smooth structured top, clean tapered sides. Right side profile showing the sleek profile line from forehead to nape. High detail, sharp focus, magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, neutral warm background. South Asian male in white wedding sherwani. Hair slicked back with pomade, smooth structured top, clean tapered sides. Three-quarter left angle showing both the face and the swept-back hair structure. High detail, sharp focus, magazine quality.

---

### 2. Korean Wolf Cut (`sample_wolf_cut`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio soft lighting, neutral background. East Asian person, medium-length dark hair. Wolf cut — heavily layered with shaggy ends. Back view, no face visible, showing the V-shaped layered hemline at the back. High detail, sharp focus, K-pop editorial quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio soft lighting, neutral background. East Asian person, medium-length dark wolf cut — layered, shaggy, textured ends. Right side profile showing the layered silhouette and curtain-style framing. High detail, sharp focus, K-pop editorial quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio soft lighting, neutral background. East Asian person, dark wolf cut — shaggy layers, curtain bangs. Three-quarter angle showing face-framing layers and the textured shaggy body of the cut. High detail, sharp focus, K-pop editorial quality.

---

### 3. Indian Bridal Updo (`sample_indian_wedding_updo`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, warm golden background. South Asian woman in red bridal lehenga with gold jewellery. Elaborate bridal updo — ornate bun decorated with marigold flowers and gold pins. Back view, no face visible, showing the full updo architecture and accessories. High detail, sharp focus, bridal magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, warm golden background. South Asian woman in red bridal lehenga. Elaborate bridal updo with floral accessories and gold pins. Right side profile showing the swept-up silhouette and decorative elements. High detail, sharp focus, bridal magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, warm golden background. South Asian woman in red bridal lehenga with gold jewellery. Elaborate bridal updo with marigold flowers and pins. Three-quarter angle showing both the bride's face and the ornate updo structure behind. High detail, sharp focus, bridal magazine quality.

---

### 4. French Crop Fade (`sample_french_crop_fade`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, grey neutral background. Young male, neutral ethnicity. French crop — short textured fringe on top, high skin fade on sides and back. Back view, no face visible, showing the crisp fade gradient from skin to hair across the back. High detail, sharp focus, barbershop quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, grey neutral background. Young male, neutral ethnicity. French crop — short textured fringe, high skin fade. Right side profile showing the fade line and the cropped top. High detail, sharp focus, barbershop quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, grey neutral background. Young male, neutral ethnicity. French crop — short textured fringe, high skin fade. Three-quarter angle showing the textured crop and fade transition on the side. High detail, sharp focus, barbershop quality.

---

### 5. Beach Waves (`sample_beach_blonde_waves`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, natural soft lighting, neutral background. Woman, light skin, golden blonde hair. Beach waves — loose sun-kissed wavy hair falling past shoulder length. Back view, no face visible, showing the full wave pattern and golden highlights throughout. High detail, sharp focus, lifestyle magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, natural soft lighting, neutral background. Woman, light skin, golden blonde beach waves past shoulders. Right side profile showing wave texture cascading from crown to tips. High detail, sharp focus, lifestyle magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, natural soft lighting, neutral background. Woman, light skin, golden blonde beach waves. Three-quarter angle showing the face-framing waves and loose beach texture falling over the shoulder. High detail, sharp focus, lifestyle magazine quality.

---

### 6. Curtain Bangs (`sample_curtain_bangs`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, soft warm background. Woman, neutral ethnicity, medium brown wavy hair with curtain bangs. Back view, no face visible, showing the medium-length waves and overall hair shape. High detail, sharp focus, salon magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, soft warm background. Woman, neutral ethnicity, medium brown hair with curtain bangs parted in the centre and swept to both sides. Right side profile showing the bang sweep and layered length. High detail, sharp focus, salon magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, soft warm background. Woman, neutral ethnicity, medium brown hair with curtain bangs. Three-quarter angle showing the centre-parted bangs framing the face and the flowing layers. High detail, sharp focus, salon magazine quality.

---

### 7. Buzz Cut (`sample_buzz_cut`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, neutral background. Athletic male, neutral ethnicity. Grade 2 buzz cut, uniform ultra-short length, natural dark hair. Back view, no face visible, showing perfectly even cut across the back of the head and nape. High detail, sharp focus, magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, neutral background. Athletic male, neutral ethnicity. Grade 2 buzz cut, uniform ultra-short, natural dark hair. Right side profile showing the clean uniform texture and neckline. High detail, sharp focus, magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, neutral background. Athletic male, neutral ethnicity. Grade 2 buzz cut, uniform ultra-short, natural dark hair. Three-quarter angle showing the even texture and shape of the buzz cut. High detail, sharp focus, magazine quality.

---

### 8. Classic Pompadour (`sample_classic_pompadour`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, dark neutral background. Male, neutral ethnicity. Classic pompadour — voluminous swept-back dark hair on top, tight tapered sides. Back view, no face visible, showing the pompadour mound shape and tapered back. High detail, sharp focus, barber magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, dark neutral background. Male, neutral ethnicity. Classic pompadour — voluminous swept-back dark hair, tight tapered sides. Right side profile dramatically showing the tall pompadour volume above the tight low sides. High detail, sharp focus, barber magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, dark neutral background. Male, neutral ethnicity. Classic pompadour — voluminous swept-back dark hair, tight tapered sides. Three-quarter angle showing both the swept volume and the tapered side. High detail, sharp focus, barber magazine quality.

---

### 9. Man Bun (`sample_man_bun`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, natural neutral background. Male with medium-long brown hair. Man bun — hair pulled back into a relaxed bun at the crown. Back view, no face visible, clearly showing the bun placement and gathered hair from behind. High detail, sharp focus, magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, natural neutral background. Male with medium-long brown hair. Man bun — relaxed bun at crown, loose texture. Right side profile showing the pulled-back silhouette and bun position at the top of the head. High detail, sharp focus, magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, natural neutral background. Male with medium-long brown hair. Man bun — relaxed bun at crown, loose natural strands. Three-quarter angle showing face framing and the bun structure behind. High detail, sharp focus, magazine quality.

---

### 10. Disconnected Undercut (`sample_disconnected_undercut`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, dark background. Male, neutral ethnicity, dark hair. Disconnected undercut — shaved sides and back with zero guard, long flowing top hair. Back view, no face visible, showing the sharp disconnection line between shaved sides and long top. High detail, sharp focus, magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, dark background. Male, neutral ethnicity, dark hair. Disconnected undercut — fully shaved sides, long top swept to one side. Right side profile showing the dramatic contrast between skin-shaved side and the long overhanging top hair. High detail, sharp focus, magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, dark background. Male, neutral ethnicity, dark hair. Disconnected undercut — shaved sides, long textured top. Three-quarter angle showing the undercut disconnection and the long top falling naturally. High detail, sharp focus, magazine quality.

---

### 11. Textured Quiff (`sample_textured_quiff`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, grey background. Male, neutral ethnicity, medium brown hair. Textured quiff — voluminous tousled front swept upward, faded sides, matte finish. Back view, no face visible, showing the tapered back with medium fade. High detail, sharp focus, magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, grey background. Male, neutral ethnicity, medium brown hair. Textured quiff — swept-up front, faded sides. Right side profile showing the quiff height and the fade gradient. High detail, sharp focus, magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, grey background. Male, neutral ethnicity, medium brown hair. Textured quiff — tousled swept-up top, faded sides, matte texture. Three-quarter angle showing the swept quiff and the side fade together. High detail, sharp focus, magazine quality.

---

### 12. Classic Bob (`sample_classic_bob`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, clean white background. Woman, neutral ethnicity, rich dark brown hair. Classic bob — blunt cut ending at chin length, perfectly straight and symmetrical. Back view, no face visible, showing the clean blunt hemline across the back of the neck. High detail, sharp focus, salon magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, clean white background. Woman, neutral ethnicity, rich dark brown hair. Classic bob — blunt chin-length cut, straight and sleek. Right side profile showing the sharp blunt edge and the clean jaw-length line. High detail, sharp focus, salon magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, clean white background. Woman, neutral ethnicity, rich dark brown hair. Classic bob — chin-length blunt cut, sleek finish. Three-quarter angle showing the clean bob shape and blunt ends framing the face. High detail, sharp focus, salon magazine quality.

---

### 13. Pixie Cut (`sample_pixie_cut`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, neutral background. Woman, neutral ethnicity, dark hair. Pixie cut — very short all over, tapered nape, slightly longer on top. Back view, no face visible, showing the closely cropped nape and tapered back. High detail, sharp focus, editorial magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, neutral background. Woman, neutral ethnicity, dark hair. Pixie cut — closely cropped sides and nape, textured top. Right side profile showing the dramatically short profile and slight length on top. High detail, sharp focus, editorial magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, neutral background. Woman, neutral ethnicity, dark hair. Pixie cut — close crop, textured top. Three-quarter angle showing the face-framing short texture and the cropped side. High detail, sharp focus, editorial magazine quality.

---

### 14. Long Straight (`sample_long_straight`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, clean neutral background. Woman, neutral ethnicity, very dark black hair. Long straight hair — sleek, pin-straight, flowing well past the shoulders. Back view, no face visible, showing the full glossy straight length from crown to waist. High detail, sharp focus, magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, clean neutral background. Woman, neutral ethnicity, very dark straight hair past shoulders. Right side profile showing the sleek straight silhouette from crown to tips. High detail, sharp focus, magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, clean neutral background. Woman, neutral ethnicity, very dark long straight hair. Three-quarter angle showing the glossy straight flow over the shoulder and the clean blunt ends. High detail, sharp focus, magazine quality.

---

### 15. Side Swept Bangs (`sample_side_swept_bangs`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, warm neutral background. Woman, neutral ethnicity, caramel brown wavy hair. Side-swept bangs, medium-long layers. Back view, no face visible, showing the caramel waves and layered ends past shoulder length. High detail, sharp focus, salon magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, warm neutral background. Woman, neutral ethnicity, caramel brown wavy hair. Side-swept bangs swept to the right side, medium wavy layers. Right side profile showing the bang sweep and the flowing layers. High detail, sharp focus, salon magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, warm neutral background. Woman, neutral ethnicity, caramel brown wavy hair. Side-swept bangs, romantic layers. Three-quarter angle showing the bang sweep direction and layered wave texture. High detail, sharp focus, salon magazine quality.

---

### 16. Braided Bridal (`sample_braided_bridal_updo`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio soft lighting, elegant background. South Asian woman in bridal attire. Intricate braided updo — multiple braids woven into an elaborate bun. Back view, no face visible, showing the full braid architecture and updo structure. High detail, sharp focus, bridal magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio soft lighting, elegant background. South Asian woman in bridal attire. Braided bridal updo — woven braids pinned elegantly. Right side profile showing the braid lines sweeping up to the pinned updo. High detail, sharp focus, bridal magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio soft lighting, elegant background. South Asian woman in bridal attire. Braided bridal updo with intricate woven braid details. Three-quarter angle showing both the bride's face and the braid detailing sweeping back. High detail, sharp focus, bridal magazine quality.

---

### 17. Reception Waves (`sample_reception_waves`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio glamour lighting, elegant dark background. Woman, light skin, champagne-gold blonde hair. Large flowing Hollywood waves past shoulders. Back view, no face visible, showing the full wave pattern in champagne gold tones. High detail, sharp focus, glamour magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio glamour lighting, elegant dark background. Woman, light skin, champagne-gold blonde Hollywood waves. Right side profile showing the sweeping wave silhouette cascading from crown. High detail, sharp focus, glamour magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio glamour lighting, elegant dark background. Woman, light skin, champagne-gold Hollywood waves. Three-quarter angle showing the glamorous wave texture and golden highlights over the shoulder. High detail, sharp focus, glamour magazine quality.

---

### 18. Platinum Blonde (`sample_platinum_blonde`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, clean white-grey background. Woman, fair skin, ice-platinum blonde hair. Platinum blonde — pure white-blonde root to tip, medium length, sleek finish. Back view, no face visible, showing the uniform platinum colour and sleek texture. High detail, sharp focus, editorial magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, clean white-grey background. Woman, fair skin, ice-platinum blonde medium-length sleek hair. Right side profile showing the striking platinum colour and the clean cut line. High detail, sharp focus, editorial magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, clean white-grey background. Woman, fair skin, ice-platinum blonde hair. Three-quarter angle showing the bold platinum colour and sleek texture framing the face. High detail, sharp focus, editorial magazine quality.

---

### 19. Balayage (`sample_balayage_highlights`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio soft lighting, neutral background. Woman, neutral ethnicity, dark brown hair with balayage. Hand-painted honey and caramel highlights blending from dark roots to lighter ends, medium-long wavy length. Back view, no face visible, showing the full colour transition from dark root to honey tips. High detail, sharp focus, salon magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio soft lighting, neutral background. Woman, neutral ethnicity, balayage — dark brown roots blending to honey caramel ends, wavy. Right side profile showing the colour gradient and wave texture. High detail, sharp focus, salon magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio soft lighting, neutral background. Woman, neutral ethnicity, balayage — dark to honey caramel wave. Three-quarter angle showing the dimensional balayage colour and natural wave movement over the shoulder. High detail, sharp focus, salon magazine quality.

---

### 20. Ivy League (`sample_ivy_league`)

**`_3` — Back view:**
> Photorealistic professional portrait photograph, studio lighting, clean light background. Male, neutral ethnicity, medium brown hair. Ivy League cut — slightly longer crew cut with neat side part, clean tapered back and sides. Back view, no face visible, showing the clean taper and well-groomed neckline. High detail, sharp focus, preppy magazine quality.

**`_4` — Side profile:**
> Photorealistic professional portrait photograph, studio lighting, clean light background. Male, neutral ethnicity, medium brown hair. Ivy League cut — side-parted longer crew cut, tapered sides. Right side profile showing the clean part line and polished taper. High detail, sharp focus, preppy magazine quality.

**`_5` — 3/4 angle:**
> Photorealistic professional portrait photograph, studio lighting, clean light background. Male, neutral ethnicity, medium brown hair. Ivy League cut — side part, polished finish, clean taper. Three-quarter angle showing the part and the structured side. High detail, sharp focus, preppy magazine quality.
