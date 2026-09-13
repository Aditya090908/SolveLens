# SolveLens — Phase 1 PRD

## Product
Name: SolveLens

Tagline: See Problems. Get Answers.

## Goal
Build the foundation of an AI-powered math problem-solving app for students.

Phase 1 is UI-only. No AI functionality is implemented yet.

## Phase 1 Home Screen

The home screen must contain:

1. SolveLens branding/name at the top-left.
2. Settings button at the top-right.
3. A visually distinctive mathematical hero area.
4. Main headline:
   "What can I solve for you today?"
5. Supporting text:
   "Ask a question, take a photo, or use your voice."
6. A bottom input bar.
7. A plus button for future camera/gallery functionality.
8. A text input field with placeholder:
   "Ask anything..."
9. A microphone button for future voice input.

## Visual Direction

The interface should feel:
- Modern
- Mathematical
- Premium
- Friendly
- Spacious
- Distinctive rather than a generic ChatGPT clone

Primary visual identity:
- Purple
- Blue
- Pink
- Gradient accents

Light mode:
- Soft off-white background
- Dark charcoal text
- Purple/blue/pink accents
- Subtle mathematical visual elements
- Soft translucent surfaces

Dark mode:
- Deep navy/near-black background
- Light text
- Purple/blue/pink accents
- Subtle glowing mathematical elements

## Responsive Design

The home screen must work properly on Android phone screen sizes and orientations normally supported by the app.

## Scope

Phase 1 includes only the visual home-screen foundation and theme system.

## Explicitly Out of Scope

Do NOT implement:
- AI API integration
- Camera functionality
- Gallery functionality
- Voice recognition
- Login/authentication
- User profiles
- History
- Practice mode
- Similar-question features
- Leaderboards
- Ads
- Backend
- Database
- Bottom navigation
- Payments

These belong to later phases.

## Acceptance Criteria

Phase 1 is complete when:
- The app launches successfully on the Android emulator.
- SolveLens branding is visible.
- Light and dark themes work.
- The home screen matches the specified visual direction.
- Input, plus, microphone, and settings controls are visually present.
- No out-of-scope functionality is implemented.
- `flutter analyze` reports no issues.
- Existing tests continue to pass.
