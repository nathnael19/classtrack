# Design System: ClassTrack

**Project ID:** 1982327003376691595

## 1. Visual Theme & Atmosphere

ClassTrack features a modern, clean, and professional aesthetic designed for educational environments. The interface is "Airy" and "Approachability-focused," utilizing ample whitespace and rounded geometries to create a friendly user experience. The design balances utility with visual appeal, making it suitable for both students and lecturers.

## 2. Color Palette & Roles

- **Primary Blue (`#3f68e4`)**: Used for primary actions, branding elements, and active states. It conveys trust and reliability.
- **Background White (`#ffffff`)**: The main canvas color, providing a clean and distraction-free environment.
- **Text Dark (`#000000`)**: Used for primary text content to ensure high readability.
- **Subtle Gray (`#f0f0f0`)**: Likely used for backgrounds of cards or secondary areas to provide depth without clutter.
- **Error Red**: (Specific hex to be confirmed from screens, typically standard error color) Used for alerts like "GPS Weak Signal" or "Outside Geofence".
- **Success Green**: (Specific hex to be confirmed) Used for "Attendance Success State".

## 3. Typography Rules

- **Font Family**: `Lexend`. This font is chosen for its readability and modern geometric feel, which aligns with the educational context.
- **Headings**: Bold weight, used for screen titles (e.g., "Student Dashboard") and section headers.
- **Body Text**: Regular weight, used for informational text and instructions.
- **Labels**: Medium/Semi-bold weight, used for buttons and navigation items.

## 4. Component Stylings

- **Buttons**:
  - **Primary**: Pill-shaped (`rounded-full` or highly rounded), filled with Primary Blue (`#3f68e4`), white text.
  - **Secondary/Outline**: Rounded, outlined with Primary Blue or Gray.
- **Cards/Containers**:
  - **Roundedness**: `ROUND_EIGHT` (approx. 32px or similar large radius) giving a soft, organic feel.
  - **Shadows**: Soft, diffused shadows to lift elements off the background (`elevation-2` or similar).
- **Inputs**:
  - Rounded edges, light gray background or border, clear focus states.

## 5. Layout Principles

- **Spacing**: Generous margins and padding (likely 16px or 24px base units) to prevent overcrowding.
- **Alignment**: Center-aligned for key interactions (like scanning QR codes) and left-aligned for lists and forms.
- **Device Target**: Mobile-first design, optimized for touch interactions.
