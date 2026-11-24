> **Navigation:** [← Category Index](../README.md) · [← Modules Master Index](../../README.md) · **Spec** · [Plan](./plan.md) · [Task](./task.md) · [Test](./test.md)

# Mobile Authentication, Deep-Link Google OAuth, 2FA Verify & Biometric App Lock

| Field | Value |
| :--- | :--- |
| **Module Slug** | `mobile-auth` |
| **Category** | `08-mobile-application` — BrandHub Mobile Application (Expo SDK 58 / React Native 0.88) |
| **Canonical Actors / Roles** | `Guest, Owner, Manager, Creator, Client, Admin` |
| **Consolidated Feature Scopes** | `mobile-auth`, `mobile-native-enhancements (Biometric AppLockGate & SecureStore)` |
| **Aligned SRS Domains** | [3.2 Authentication & Authorization](../../../srs/01-authentication/README.md) (`3.2.1–3.2.9`) |
| **Status** | Implemented — Production Verified |

## 1. Objective & Architectural Motivation

Deliver production-grade authentication and on-device session security on `brandhub-mobile-app` (Expo SDK 58, React Native 0.88): Email/Password Sign In, Sign Up + 60s OTP Verification, Forgot/Reset Password + Account Activation deep links, **Google OAuth (`expo-web-browser` / `expo-auth-session` via `?client=mobile` -> `brandhub://oauth-callback`)**, 2FA TOTP verification, `expo-secure-store` token persistence with single-flight refresh, and **Biometric / Device-Passcode `AppLockGate`** (`expo-local-authentication`).

## 2. User Stories

- As a mobile user (`Guest -> Owner / Manager / Creator / Client / Admin`), I want seamless Email, OTP, 2FA, and Google OAuth sign-in plus optional FaceID/TouchID/Passcode App Lock after `60s` in background so client data on my phone stays protected.

## 3. Consolidated Acceptance Criteria

1. **Complete Auth Screen Stack (`AuthNavigator.tsx`):** `LoginScreen.tsx`, `RegisterScreen.tsx`, `VerifyOtpScreen.tsx` (60s resend timer), `ForgotPasswordScreen.tsx`, `ResetPasswordScreen.tsx`, `TwoFactorVerifyScreen.tsx`, and `ActivateAccountScreen.tsx` wired to `authService.ts` and `authStore.ts`.
2. **Mobile Google OAuth (`2026-11-11-mobile-google-oauth-link.sql`):** Initiates `/api/v1/auth/oauth/google?client=mobile` inside `expo-web-browser` system auth session and handles `brandhub://oauth-callback` deep-link token exchange cleanly.
3. **`expo-secure-store` Single-Flight Refresh & Safe Sign-Out:** `api.ts` queues concurrent `401` requests behind one `/api/v1/auth/refresh` call; `confirmSignOut.ts` revokes server session, wipes `SecureStore`, clears `TanStack Query` caches, and cancels scheduled local task reminders.
4. **Biometric / Passcode `AppLockGate` (`mobile-native-enhancements` AC-L1..L7):** `AppLockGate.tsx` (`appLock.ts` + `deviceFeaturesStore.ts`) requires successful `expo-local-authentication` check to enable/disable, locks on cold launch and after `>= 60s` background (including backward clock-tamper guard), blocks Android hardware Back & screen-reader leakage while locked, always provides an emergency Sign Out escape hatch, and preserves active screen/drafts/uploads upon unlock.
5. **Internationalization (`vi.json` + `en.json`):** Every user-facing string, tooltip, dialog prompt, status badge, and error banner uses key-parallel translations (`src/i18n/locales/en.json` & `src/i18n/locales/vi/common.json` (`auth.*`, `security.appLock.*`, `api-errors.vi.json` via `tr()`)) on `brandhub-web` and `tr()` (`en.json` + `vi/common.json`) on `brandhub-mobile-app` with zero hardcoded Vietnamese or English strings in JSX/TSX.
6. **Light & Dark Mode Compliance:** All surfaces, drawers, badges, charts, and interactive controls use semantic CSS variables / Tailwind `dark:` variants on Web and `useAppPreferences().palette` tokens on Mobile, achieving WCAG AA contrast in both Light and Dark themes.

## 4. UI / UX Surfaces & Lifecycle States

- **Web Surfaces (`brandhub-web`):** Parity with `pages/auth/{LoginPage,RegisterPage,VerifyOtpPage,TwoFactorVerifyPage,OAuthCallbackPage,ActivateAccountPage}.tsx`
- **Mobile Surfaces (`brandhub-mobile-app`):** `src/navigation/AuthNavigator.tsx`, `src/screens/auth/*`, `src/screens/settings/SecuritySettingsScreen.tsx`, `src/components/common/AppLockGate.tsx`, `src/store/{authStore,deviceFeaturesStore}.ts`
- **UI States:**
  - **Loading / Streaming:** Deterministic skeleton placeholders, progress bars, and disabled submit buttons preventing duplicate requests.
  - **Empty / Onboarding:** Contextual empty state with localized call-to-action and zero fabricated mock fallback data.
  - **Active / Realtime Sync:** Scoped `TanStack Query` cache updates + WebSocket/SSE/polling synchronization where applicable.
  - **Error / Conflict Recovery:** Actionable localized error banners (`400/403/404/409/429/503`) preserving unsaved user input.

## 5. API, Messaging & Protocol Contract

| Route / Channel / Filter | Auth / Scope | Service & Handler |
| :--- | :--- | :--- |
| `POST /api/v1/auth/{login|register|verify-otp|resend-otp|forgot-password|reset-password|2fa/verify|refresh|logout}` | Guest / Bearer | `AuthController` (`brandhub-business-service`) <- `src/services/authService.ts` |
| `GET /api/v1/auth/oauth/google?client=mobile -> brandhub://oauth-callback` | OAuth 2.0 Redirect | `GoogleOAuthController` -> `expo-web-browser` / `expo-linking` |
| `POST /api/v1/auth/activation/{verify|complete}` | Activation Token | `AccountActivationController` <- `ActivateAccountScreen.tsx` |

## 6. Error Handling, Security & Edge Cases

- **Device Without OS Screen Lock Enrolled:** `AppLockGate` blocks enabling App Lock with a localized prompt guiding user to OS Security Settings.
- **Clock Rolled Back While Backgrounded:** Monotonic/timestamp delta check forces lock if elapsed `< 0` or `>= 60,000 ms`.

## 7. Related Specifications & References

- **Aligned SRS Functional Requirements:** [3.2 Authentication & Authorization](../../../srs/01-authentication/README.md) (`3.2.1–3.2.9`)
- **BA & Architecture References:** [BA 02 Authentication & Profile](../../../../ba/02-authentication-profile.md) · [Roles & Permissions Matrix](../../../../ba/10-roles-permissions-matrix.md)

## 8. Definition of Done & Out of Scope

- **Definition of Done:** Production code verified across backend, AI/publisher workers, Web, and Mobile; `vi.json` + `en.json` parity verified; Light/Dark mode audited; all automated verification suites in [test.md](./test.md) passing.
- **Out of Scope:** De-scoped SRS items (livestream features, subscription plan downgrades, PayOS/VNPay/Stripe gateways, Zalo OA publishing, or copyright/plagiarism scanning).
