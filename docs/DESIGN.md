# SolveLens — Phase 1 Design Specification

## Design Goal

Create a premium, modern mathematical interface that feels distinctive and visually memorable.

The design must NOT look like a generic ChatGPT clone.

The interface should feel:
- Modern
- Mathematical
- Premium
- Friendly
- Spacious
- Calm
- Slightly futuristic

## Brand

App name:
SolveLens

Tagline:
See Problems. Get Answers.

The SolveLens name should be visually prominent but not oversized.

## Color Identity

The primary visual identity uses:
- Purple
- Blue
- Pink
- Smooth gradient transitions between these colors

Gradients should be used as accents rather than covering the entire interface.

## Light Theme

Background:
- Soft off-white / very light neutral

Primary text:
- Dark charcoal

Secondary text:
- Muted gray

Accent:
- Purple / blue / pink gradients

Surfaces:
- Soft translucent or lightly elevated surfaces
- Rounded corners
- Subtle shadows where appropriate

The result should feel bright, clean, and premium rather than pure white.

## Dark Theme

Background:
- Deep navy / near-black

Primary text:
- White or very light gray

Secondary text:
- Muted gray

Accent:
- Purple / blue / pink gradients

Visual effects:
- Very subtle glow around selected accent elements
- Mathematical elements should blend naturally into the background

The dark theme must remain comfortable to read and must not become visually noisy.

## Home Screen Layout

The screen should be vertically structured with generous spacing.

### Top Area

Top-left:
- SolveLens branding/name

Top-right:
- Settings icon button

The top area should have comfortable safe-area padding.

### Hero Area

The center/upper-middle portion should contain a distinctive mathematical visual.

Possible visual language:
- Geometric shapes
- Mathematical symbols
- Equations
- Graphs
- Lines and nodes
- Subtle mathematical diagrams

The visual should be decorative and brand-oriented.

It must not look like a stock image.

In dark mode, mathematical elements may have a subtle glow.

### Main Headline

Display:

"What can I solve for you today?"

This is the main focal point of the screen.

Typography:
- Large
- Clear
- Modern
- Strong visual hierarchy
- Responsive to phone width

### Supporting Text

Display:

"Ask a question, take a photo, or use your voice."

Use smaller secondary typography.

The supporting text should visually sit below the headline without competing with it.

## Input Area

Place the input bar near the bottom of the screen while respecting the keyboard and safe areas.

The input bar should be:
- Rounded
- Spacious
- Comfortable to tap
- Visually integrated with the current theme

Placeholder:

"Ask anything..."

The text field should support multiple lines visually if appropriate, but actual AI submission behavior is NOT part of Phase 1.

### Plus Button

Place a plus button inside or adjacent to the input bar.

The plus button represents future:
- Camera
- Gallery

Phase 1 requirement:
- Show the button visually only.
- Do NOT implement camera or gallery functionality.

### Microphone Button

Place a microphone icon button in the input area.

Phase 1 requirement:
- Show the button visually only.
- Do NOT implement speech recognition or voice processing.

## Settings Button

Show a settings icon in the top-right.

Phase 1 requirement:
- It may be visually present only.
- Do not create a settings screen unless explicitly required by the PRD.

## Mathematical Visual Language

Use mathematical concepts as part of the visual identity.

Examples:
- x²
- √x
- π
- ∑
- geometric triangles
- circles
- coordinate axes
- equations
- graphs

These should be subtle decorative elements rather than large blocks of text.

Avoid excessive decoration.

## Typography

Use Flutter's standard typography system or a simple bundled/system-safe font approach.

Prioritize:
- Readability
- Clear hierarchy
- Consistent font weights
- Comfortable line height

Do not add a custom font package unless there is a clear reason.

## Shapes

Prefer:
- Rounded cards
- Rounded input field
- Circular or rounded icon buttons
- Smooth geometry

Avoid:
- Excessive sharp rectangular containers
- Heavy borders
- Dense UI

## Motion

Use subtle animations where they improve polish.

Appropriate examples:
- Gentle entrance animation for hero content
- Small fade/slide transitions
- Subtle interaction feedback on buttons

Animations must:
- Be short
- Feel smooth
- Not distract from the math-solving purpose

Do not introduce complex animation libraries.

## Responsiveness

Design for Android phones first.

The layout must adapt to:
- Different phone widths
- Different screen heights
- System safe areas
- On-screen keyboard

Avoid hardcoded screen dimensions.

Use responsive Flutter layout techniques.

## Accessibility

Ensure:
- Good text contrast
- Adequate tap target sizes
- Icons have semantic labels where appropriate
- Text does not become unreadably small

## Component Boundaries

Keep Phase 1 architecture simple.

Reasonable components may include:
- Home screen
- Hero visual
- Input bar
- Theme configuration

Do not create a large architecture or unnecessary abstraction for this phase.

## Phase 1 Restrictions

Do NOT implement:
- AI
- API calls
- Camera
- Gallery
- Voice recognition
- Authentication
- Database
- History
- Practice
- Similar questions
- Bottom navigation
- Ads
- Payments
- Backend

## Design Acceptance Criteria

The final Phase 1 UI should:
- Clearly look like SolveLens.
- Feel mathematical rather than generic.
- Use the purple/blue/pink identity.
- Have both light and dark themes.
- Have strong visual hierarchy.
- Have a distinctive hero area.
- Have the headline and supporting text specified in the PRD.
- Have the input bar, plus button, microphone button, and settings button.
- Feel spacious and premium.
- Work correctly on the Android emulator.
- Avoid unnecessary packages and complexity.
