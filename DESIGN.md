# Hair Lens - AI — Design Brief

> **How to use:** Paste any section below into Claude, Figma AI, Canva AI, or any design tool to generate that specific screen. Start with the "Master Prompt" for full app context, then use individual screen prompts.

---

## Master Prompt (Use This First)

```
Design a modern iOS app called "Hair Lens - AI" — an AI-powered hairstyle preview tool. 
Users upload a selfie, pick a hairstyle, and get a photorealistic preview where only 
their hair changes (face stays identical).

DESIGN PRINCIPLES:
- Premium feel — like a luxury beauty app (think Sephora meets ChatGPT)
- Photography-first — let user photos breathe, minimal chrome
- Confident, not playful — this is a decision-making tool
- Native iOS 18 aesthetic — uses SF Symbols, system blur, dynamic type
- Minimalist but warm — generous whitespace, soft accent colors

BRAND IDENTITY:
- Primary color: Deep purple #7C3AED (lens/AI)
- Secondary color: Coral pink #EC4899 (hair/beauty)
- Surface: Pure white #FFFFFF (light), True black #000000 (dark)
- Text primary: #18181B (light) / #FAFAFA (dark)
- Text secondary: #71717A (light) / #A1A1AA (dark)
- Accent gradient: Purple → Pink (only for hero moments)
- Border: rgba(0,0,0,0.06) light / rgba(255,255,255,0.08) dark

TYPOGRAPHY:
- Font: SF Pro (system) — Display for headers, Text for body
- H1: 34pt bold (screen titles)
- H2: 22pt semibold (section headers)
- Body: 17pt regular
- Caption: 13pt medium
- Button: 17pt semibold

SPACING:
- Tight: 8pt, Default: 16pt, Loose: 24pt, Section: 32pt
- Card corner radius: 16pt
- Button corner radius: 12pt
- Input corner radius: 12pt

KEY COMPONENTS:
- Style cards (2-column grid, 1:1.2 aspect, image + label + tag)
- Primary button (filled purple, 56pt tall, full-width)
- Photo picker (large dashed card with camera icon)
- Before/after slider (horizontal drag divider)
- Credit pill (small purple chip showing remaining credits)
```

---

## Screen 1: Onboarding (3 slides)

```
Design a 3-slide iOS onboarding for Hair Lens - AI.

SLIDE 1 — Hero
- Top: Large hero image showing a before/after split (face left, styled right)
- Title: "See Yourself With Any Hairstyle"
- Subtitle: "AI-powered previews in seconds"
- Bottom: 3 dot pagination + "Continue" button

SLIDE 2 — Value Prop
- Top: Animated illustration showing 3 style options floating
- Title: "Indian Weddings. Japanese Salons. Bold Looks."
- Subtitle: "Curated styles you won't find anywhere else"
- Bottom: 3 dot pagination + "Continue" button

SLIDE 3 — Trust + CTA
- Top: Lock icon + face icon
- Title: "Your Face Stays You"
- Subtitle: "We change only the hair. No filters, no wigs. Photorealistic results."
- Bottom: "Get 3 Free Generations" button (primary, gradient)
- Below: "Continue without account" link

Style: Full-bleed images, large bold typography, generous padding (24pt sides), 
gradient buttons for CTAs only.
```

---

## Screen 2: Home / Style Picker

```
Design the home screen for Hair Lens - AI.

LAYOUT (top to bottom):
1. Status bar (system)
2. Header bar (60pt tall):
   - Left: App logo (lens icon, 32pt)
   - Right: Credit pill "3 credits" + Settings gear icon
3. Search bar: "Search styles..." with magnifying glass icon, gray bg
4. Category chips (horizontal scroll): 
   - "All" (selected, purple bg)
   - "Wedding" 
   - "Salon"
   - "Casual"
   - "Bold"
   - "Trending"
5. Style grid (2 columns, 16pt gutter):
   - Each card: 
     - Image (1:1.2 ratio, rounded 16pt corners)
     - Style name (17pt semibold, 1 line)
     - Category tag (small purple pill below name)
     - "NEW" badge overlay if applicable
6. Bottom: Floating action button (FAB) — "Custom Style" with sparkle icon

STYLE CARDS TO SHOW:
1. "Classic Groom" — Wedding tag
2. "Korean Wolf Cut" — Salon tag (NEW badge)
3. "Indian Bridal Updo" — Wedding tag  
4. "French Crop Fade" — Casual tag
5. "Beach Waves" — Bold tag
6. "Curtain Bangs" — Salon tag

Color: White background, photos pop, minimal chrome.
```

---

## Screen 3: Style Detail / Input

```
Design the style detail screen for Hair Lens - AI where users upload their photo.

LAYOUT (top to bottom):
1. Navigation bar:
   - Left: Back chevron
   - Center: Style name "Korean Wolf Cut"
   - Right: Heart icon (favorite)
2. Style hero image (full-width, 16:9, rounded bottom corners)
3. Style description (16pt regular, 3-line max):
   "A trendy layered cut with face-framing texture and shaggy ends, 
   popularized by K-pop idols."
4. Photo upload zone:
   - Large card (180pt tall, dashed border, soft purple bg)
   - Camera icon (40pt, purple)
   - "Take or Upload Photo" (17pt semibold)
   - "Front-facing selfie, clear face" (13pt secondary)
5. Tips section (collapsible):
   - "✓ Front-facing"
   - "✓ Clear lighting"
   - "✓ No sunglasses or hat"
6. Primary CTA: "Generate Preview" button (full-width, purple, 56pt)
   - Sub-label below: "Uses 1 credit • You have 3"
7. Secondary: "Try a Custom Style Instead" link

State: Empty (no photo yet). Show photo thumbnail in upload zone after selection.
```

---

## Screen 4: Custom Prompt

```
Design a custom style input screen for Hair Lens - AI.

LAYOUT:
1. Navigation bar with "Cancel" + "Custom Style" + "Done"
2. Header: "Describe Your Dream Hairstyle"
3. Subtitle: "Be specific — length, color, texture, vibe"
4. Large text area (180pt tall, rounded 12pt):
   - Placeholder: "e.g., Long wavy beach blonde hair with side bangs..."
   - Character count: 0/200 (bottom right)
5. Quick suggestion chips (horizontal scroll):
   - "Long & wavy"
   - "Short & textured"
   - "Bold color"
   - "Vintage"
   - "Editorial"
6. Photo upload zone (same as Style Detail)
7. "Generate Preview" CTA button at bottom

Style: Conversational, AI-forward feel. Hint of sparkle/AI iconography.
```

---

## Screen 5: Generating State

```
Design the loading screen while AI generates the hairstyle preview.

LAYOUT (centered):
1. Animated illustration (200pt tall):
   - Circular lens with shimmering hair strands rotating around it
   - Subtle purple-to-pink gradient inside the lens
   - SF Symbol "wand.and.stars" pulsing in center
2. Title: "Styling your hair..." (22pt semibold)
3. Subtitle: "This usually takes 8-12 seconds" (15pt secondary)
4. Animated tips that rotate every 3s (13pt secondary):
   - "Our AI is matching the lighting to your photo..."
   - "Preserving every detail of your features..."
   - "Crafting a natural hairline..."
5. Bottom: "Cancel" link (red, subtle)

Background: Soft purple-tinted white. No other UI. Full focus on loading.
Animation: Subtle particle effects emanating from lens.
```

---

## Screen 6: Result / Before-After

```
Design the result screen showing before/after comparison.

LAYOUT (top to bottom):
1. Navigation bar:
   - Left: Back chevron  
   - Center: "Your Preview"
   - Right: Share icon
2. Before/After slider (full-width, 4:5 aspect):
   - Vertical divider line with circular handle (purple)
   - "BEFORE" label top-left (12pt, white text on dark blur)
   - "AFTER" label top-right
   - Swipeable to reveal more of either side
3. Style applied chip below image:
   - "Korean Wolf Cut" with style icon
4. Action row (4 buttons, evenly spaced):
   - Heart (save to favorites)
   - Download (save to photos)
   - Share (system share sheet)
   - Refresh (regenerate — costs 1 credit)
5. Feedback section:
   - "How does it look?" header
   - Thumbs up / Thumbs down buttons
6. CTA: "Try Another Style" (purple, full-width)
7. Bottom: "View Generation History" link

Style: Photo dominates. Minimal UI. Premium feel.
```

---

## Screen 7: Paywall / Credit Packs

```
Design the paywall screen for purchasing credits.

LAYOUT (top to bottom):
1. Close button (X) top right
2. Hero section:
   - Sparkle icon (purple, 60pt)
   - Title: "Out of Credits" (28pt bold)
   - Subtitle: "Get more previews to find your perfect look"
3. Three credit pack cards (vertical stack, 16pt gap):
   
   STARTER PACK:
   - 10 credits • ₹199 (or ¥299 / $2.99)
   - "Try a few styles"
   
   STANDARD PACK ⭐ (highlighted, purple border):
   - 30 credits • ₹499 (or ¥799 / $7.99)
   - "Best value — Save 16%"
   - "BEST VALUE" ribbon
   
   PRO PACK:
   - 100 credits • ₹1,499 (or ¥2,399 / $19.99)
   - "For serious style hunters"
   
   Each card: Image left, details right, radio button right edge

4. Selected pack appears in primary CTA button:
   "Continue with Standard — ₹499"
5. "Restore Purchase" link below button
6. Terms / Privacy links at very bottom (11pt)

Style: Aspirational, trustworthy, not pushy. Standard pack highlighted with 
subtle gradient border.
```

---

## Screen 8: History

```
Design the generation history screen.

LAYOUT:
1. Navigation bar: "History" title, "Edit" button right
2. Filter chips (horizontal scroll):
   - "All", "Favorites", "Last 7 days", "By style"
3. Grid of past generations (2 columns):
   - Square thumbnails (rounded 12pt)
   - Style name below
   - Date generated (small, secondary)
   - Heart icon if favorited (top right of thumbnail)
4. Empty state (when no history):
   - Centered illustration of empty lens
   - "No previews yet"
   - "Your generation history will appear here"
   - CTA: "Browse Styles"

Tap any item → opens full Result screen.
Long-press → options (favorite, delete, share, regenerate).
```

---

## Screen 9: Settings

```
Design the settings screen for Hair Lens - AI.

LAYOUT (grouped list, iOS native style):

SECTION 1 — Account
- Credits Remaining: "3" (with "+ Get More" button)
- Restore Purchases (link)

SECTION 2 — Preferences  
- Appearance: Light / Dark / System (segmented)
- Save originals to Photos (toggle)
- Haptic feedback (toggle)

SECTION 3 — About
- Rate Hair Lens - AI (with star icon)
- Share App (with share icon)
- Help & FAQ (with question icon)
- Contact Support (with mail icon)

SECTION 4 — Legal
- Privacy Policy
- Terms of Service
- Acknowledgments

SECTION 5 — Danger Zone
- Clear History (red text)
- Delete All Data (red text)

Footer: "Hair Lens - AI v1.0 (Build 1) • Made with ❤️ by Shubham"
```

---

## Screen 3b: Style Detail — Reference Photo Mode (V2)

```
Add a second optional photo zone below the primary selfie upload zone.

REFERENCE PHOTO ZONE:
- Same dashed-border card as primary upload zone but smaller (120pt tall)
- Icon: photo.on.rectangle (SF Symbol, purple, 28pt)
- Label: "Add reference photo" (15pt semibold)
- Sublabel: "We'll copy that exact style" (13pt secondary)
- Optional — greyed "Skip" label if not needed

BEHAVIOUR:
- When filled: shows thumbnail + "× Remove" same as primary zone
- CTA sub-label updates: "Generate Preview · matches reference photo"
- Stacked below primary zone with 12pt gap and a thin divider labelled "Optional"
```

---

## Screen 2b: Home — Beard Category (V2)

```
Add "Beard" to the category chip row between "Bold" and "Trending":
  All · Wedding · Salon · Casual · Bold · Beard · Trending

BEARD STYLE CARDS (5):
- "Clean Shave"     — Casual tag
- "Short Box Beard" — Salon tag
- "Full Beard"      — Bold tag
- "Goatee"          — Casual tag
- "Designer Stubble"— Salon tag

Style Detail for beard cards:
- Hero shows before/after of beard change on a model face (not hair change)
- Beard toggle on Style Detail: "Style beard too?" (toggle, default off)
  → when on, CTA becomes "Generate Preview (hair + beard)" and uses combined prompt
- Tips section updated: "Front-facing · Even jaw lighting · No scarf or face mask"
```

---

## App Icon Design

```
Design the iOS app icon for Hair Lens - AI (1024×1024).

CONCEPT:
- Centered lens/circle in white on gradient background
- Flowing hair strands (8) emerging through the lens
- Inner concentric circles (subtle, AI-inspired)
- Background: Purple #7C3AED to Pink #EC4899 diagonal gradient

STYLE:
- Premium, modern, beauty-tech aesthetic
- Recognizable at small sizes (40pt)
- iOS rounded corner mask (256pt radius)
- No text (visual only)
- Subtle shine on the lens glass

AVOID:
- Realistic hair textures (looks generic)
- Photographs of people
- Multiple competing elements
- Sharp contrasts that hurt at small sizes
```

---

## Component Library

### Buttons
```
Primary: Filled purple (#7C3AED), white text, 56pt tall, 12pt radius, full-width
Secondary: White with purple border, purple text, 56pt tall
Tertiary: Text only, no background, purple color
Destructive: Red text (#EF4444)
Disabled: 30% opacity
```

### Style Card
```
- 1:1.2 aspect ratio
- 16pt corner radius
- Image fills card
- Bottom gradient overlay (black 0% → 60%)
- Style name: white, 15pt semibold, bottom-left
- Category tag: small pill, top-right, frosted glass effect
- Tap: subtle scale-down (0.96) + haptic
```

### Credit Pill
```
- Background: purple with 10% opacity
- Border: purple with 30% opacity
- Text: purple #7C3AED, 13pt semibold
- Format: "💎 3" or just "3 credits"
- Height: 28pt, 12pt horizontal padding
```

### Photo Upload Zone (Empty)
```
- Dashed border 2pt (purple at 30% opacity)
- Background: very light purple (#F5F3FF)
- Camera icon centered (40pt, purple)
- Two-line text below
- Min height: 180pt
- Corner radius: 16pt
- Tap: opens camera/library action sheet
```

### Photo Upload Zone (Filled)
```
- No border
- Selected photo fills (16pt radius)
- Small "X" button top-right to remove
- Tap photo: replace
```

---

## Animation Specs

```
Page transitions: iOS default push (350ms ease-in-out)
Modal: Slide-up from bottom (400ms)
Buttons: Scale 0.96 on press, spring back (200ms)
Cards: Subtle parallax on scroll
Loading: Particle effect around lens (continuous)
Success: Confetti burst + haptic (one-time on first generation)
Slider: Spring physics (stiffness 200, damping 20)
```

---

## Dark Mode Adjustments

```
- Backgrounds invert (white → near black #0A0A0A)
- Surfaces: zinc-900 (#18181B) instead of pure black
- Text inverts (zinc-900 → zinc-50)
- Purple accent stays (works in both)
- Pink accent slightly desaturated in dark
- Borders use white at 8% opacity
- Photos gain subtle border to separate from bg
```

---

## App Store Screenshots (6 frames)

```
Frame 1: Hero — Beautiful before/after with style name overlay
"See yourself with any hairstyle"

Frame 2: Style catalog grid
"30+ curated styles. Indian. Japanese. Global."

Frame 3: Custom prompt screen
"Describe any look. AI brings it to life."

Frame 4: Result with before/after slider
"Photorealistic. Your face stays yours."

Frame 5: Privacy callout
"On-device validation. Photos never stored on our servers."

Frame 6: Pricing
"3 free previews. Then ₹199 for 10. No subscription."

Background gradient: Soft purple → pink
Device frame: iPhone 15 Pro mockup
Text: Large white SF Display Bold
```

---

## Empty States

```
NO HISTORY:
- Illustration: Empty lens with sparkle particles
- "Nothing to see... yet"
- "Your first preview is one tap away"
- CTA: "Browse Styles"

NO INTERNET:
- Illustration: Disconnected lens
- "Can't reach our servers"
- "Check your connection and try again"
- CTA: "Retry"

GENERATION FAILED:
- Illustration: Caution lens
- "Something went wrong"
- "Don't worry — your credit was refunded"
- CTA: "Try Again"
```

---

## Voice & Copy Guidelines

```
TONE: Confident, warm, premium. Not corny. Not over-friendly.

DO:
✓ "See yourself with..." (empowering)
✓ "Your face stays you" (trust)
✓ "Crafted previews" (premium)
✓ Short, declarative sentences

DON'T:
✗ "Hey there!" (too casual)
✗ "Magical AI" (overused)
✗ "Try our amazing feature" (salesy)
✗ Exclamation marks!!! (try-hard)

EXAMPLES:
- Loading: "Styling your hair..."  ✓
- Loading: "Hold tight while our magic happens!" ✗

- Error: "Generation didn't work this time. Credit refunded." ✓
- Error: "Oops! Something went wrong! Please try again!" ✗
```

---

## How to Use This Brief

### For Claude (text-to-design):
1. Paste the **Master Prompt** first to set context
2. Then paste any **individual screen prompt** to generate that screen
3. Iterate by adding: "Make it more minimal" or "Add a dark mode variant"

### For Figma AI:
1. Use screen prompts directly in Figma's AI panel
2. Apply the design system tokens manually after generation

### For Canva:
1. Use the App Store Screenshots section to create marketing assets
2. Use brand colors and typography from Master Prompt

### For yourself:
1. This doc is the single source of truth for design decisions
2. Update it as the product evolves
3. Reference it during code reviews to ensure UI matches spec

---

**Document Owner:** Shubham Raj  
**Last Updated:** May 16, 2026  
**Status:** V1 design system locked. Subject to iteration after Session 0 validation.