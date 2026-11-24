# 08-mobile-application — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) (7 Modules)

> **Navigation:** [← Feature Master Index](../../README.md) · [← Modules Master Index](../README.md) · [SRS 141 FRs](../../srs/README.md) · [BA Baseline](../../../ba/README.md) · [Architecture Overview](../../../architecture/technical-overview.md) · [Workflow Rule](../../../rule/feature-workflow.md)

Complete 7-domain engineering specification for `brandhub-mobile-app` (Expo SDK 58, React Native 0.88, TypeScript, Zustand, TanStack Query) delivering role-aware mobile parity across `Owner`, `Manager`, `Creator`, `Client`, and `Admin`.

---

## 1. Mobile Architecture & Backend Integration

- **Client Repository (`brandhub-mobile-app`):**
  - **Root Navigation (`src/navigation/AppNavigator.tsx`):** `AuthNavigator` -> `AdminStackNavigator` (system `Admin`) -> `WorkspacePickerScreen` -> `MainDrawerNavigator` (`useSidebarTree` + `WorkspaceTabBar`).
  - **State, Cache & Localization:** `authStore` & `workspaceStore` (`expo-secure-store`), TanStack Query (`queryKeys.ts`), `tr()` bilingual `vi`/`en` catalogs, and Light/Dark `useAppPreferences().palette` tokens.
  - **Native Capabilities:** `react-native-vision-camera` + custom `modules/brandhub-audio`, background multipart S3 upload queue, biometric App Lock, and `brandhub://` deep linking.
- **Backend Gateways:** Consumes `brandhub-api-gateway` (`:8080`) -> `brandhub-business-service` REST + STOMP `/ws/chat` contracts identical to `brandhub-web`.

---

## 2. Consolidated Modules (`7`)

| Module Slug | Scope & Engineering Title | Primary SRS Domain Alignment | Lifecycle Artefacts (`spec → plan → task → test`) |
| :--- | :--- | :--- | :--- |
| `mobile-auth` | **Mobile Authentication, Deep-Link Google OAuth, 2FA Verify & Biometric App Lock** | `3.2` Auth & `3.3` Profile | [Spec](./mobile-auth/spec.md) · [Plan](./mobile-auth/plan.md) · [Task](./mobile-auth/task.md) · [Test](./mobile-auth/test.md) |
| `mobile-creator-upload` | **Mobile Pro VisionCamera Capture, Offline-Resilient S3 Multipart Sync & Task Take Promotion** | `3.6.11`–`3.6.17` Repository | [Spec](./mobile-creator-upload/spec.md) · [Plan](./mobile-creator-upload/plan.md) · [Task](./mobile-creator-upload/task.md) · [Test](./mobile-creator-upload/test.md) |
| `mobile-agency-workspace` | **Mobile Role-Based Navigation Parity, Three-Tier Dashboards & Agency/Workspace Directory** | `3.4` Agency & Workspace | [Spec](./mobile-agency-workspace/spec.md) · [Plan](./mobile-agency-workspace/plan.md) · [Task](./mobile-agency-workspace/task.md) · [Test](./mobile-agency-workspace/test.md) |
| `mobile-package-campaign` | **Mobile Media Package Review, Campaign Tracking & Client Content Request Workflows** | `3.5` Package & Campaign | [Spec](./mobile-package-campaign/spec.md) · [Plan](./mobile-package-campaign/plan.md) · [Task](./mobile-package-campaign/task.md) · [Test](./mobile-package-campaign/test.md) |
| `mobile-task-workflow` | **Mobile Task List/Kanban/Calendar, Rich Content Editor, 3-Tier Approvals, Local Reminders & Chat** | `3.6` Content, Approvals & Chat | [Spec](./mobile-task-workflow/spec.md) · [Plan](./mobile-task-workflow/plan.md) · [Task](./mobile-task-workflow/task.md) · [Test](./mobile-task-workflow/test.md) |
| `mobile-ai-features` | **Mobile AI Hub: Grounded Captions, Hashtag Suggestions, Ambassadors, Ad Images, Video & Quick Reel Studio** | `3.7` AI Features | [Spec](./mobile-ai-features/spec.md) · [Plan](./mobile-ai-features/plan.md) · [Task](./mobile-ai-features/task.md) · [Test](./mobile-ai-features/test.md) |
| `mobile-subscription-billing` | **Mobile Studio & Agency Subscription Plans, SePay VietQR Checkout, AI Credit Caps & Invoice History** | `3.9` Subscription & Billing | [Spec](./mobile-subscription-billing/spec.md) · [Plan](./mobile-subscription-billing/plan.md) · [Task](./mobile-subscription-billing/task.md) · [Test](./mobile-subscription-billing/test.md) |

---

## 3. Mobile Verification Standards

1. All Jest unit/screen suites live alongside source modules under `__tests__/` (`npm test` / `npx tsc --noEmit`).
2. `workspaceStore.currentMemberRole` is re-derived per workspace switch (`GET /api/v1/workspaces/{id}`) so multi-workspace users never carry stale role permissions across tenants.
