## SINE AI Architecture (WIP migration)

### Goal
Move to a **feature-based**, scalable folder structure **without breaking existing working flows**.

### Important
- Existing working screens/services in `lib/screens/`, `lib/services/`, `lib/widgets/`, `lib/theme/`, `lib/localization/` are currently the runtime source of truth.
- The new folders under `lib/features/`, `lib/shared/`, `lib/core/` are being introduced as **stable entry points**.
- During migration, most files inside `lib/features/**` will initially `export` existing implementations to avoid risky moves/refactors.

### New top-level buckets
- `lib/core/`: cross-cutting utilities, constants, routing (to be introduced gradually)
- `lib/shared/`: reusable UI components (design system building blocks)
- `lib/features/`: feature modules (aura/chat/alerts/profile/settings)

