# UI/UX Wireframes, Design System & Frontend Architecture (`docs/wireframe/`)

> Navigation: [← Knowledge Base Hub](../index.md) · [BA Specifications](../ba/README.md) · [UI Screenshots (`D15`–`D19`)](../screenshots/README.md) · [V1 Legacy Wireframe Archive](../archive/v1-legacy/README.md)

This directory contains BrandHub's **V2/V3 UI/UX wireframe architecture and frontend implementation checklist** aligned with the production `brandhub-web` (`React 19.2` + `Vite 8.3` + `Tailwind CSS 4.3`) and `brandhub-mobile-app` (`Expo SDK 58` + `React Native 0.88`) applications across Desktop (`1440px`) and Mobile (`375px`) viewports.

---

## 1. Authoritative V2/V3 Specifications

| Document | Scope |
| :--- | :--- |
| [wireframe-blueprint.md](./wireframe-blueprint.md) | **Primary V2/V3 Wireframe & Solutions Architecture Blueprint**: 11 core screen layouts (`Login/Auth`, `Agency Directory & Dashboard`, `Workspace Dashboard & Personal Launchpad`, `Package/Campaign Negotiation & Timeline`, `4-View Task Board`, `Multi-Section Content & AI Studio Editor`, `Content Calendar`, `Client Portal`, `Collaborator Directory`, `Analytics`, `Admin Console`) strictly enforcing the **6 Canonical Roles** (`Guest`, `Owner`, `Manager`, `Creator`, `Client`, `Admin`) and **4 social platforms** (**Facebook, Instagram, TikTok, Threads**). |
| [wireframe-to-code-checklist.md](./wireframe-to-code-checklist.md) | **Wireframe-to-Code Engineering Checklist**: 8-stage implementation contract covering `shadcn/ui` (`v4.13`) + Radix UI + `@astryxdesign/core` primitives, workspace-scoped RBAC (`useWorkspaceRole`), collaborative TipTap `3.35` + Yjs `13.6` editing, STOMP WebSockets, Agora voice/video calls, bilingual `i18next` (`vi`/`en`), and Light/Dark semantic tokens. |

---

## 2. Production Frontend Stack Snapshot (`brandhub-web` & `brandhub-mobile-app`)

| Layer | `brandhub-web` (Web Dashboard `:5173`) | `brandhub-mobile-app` (Companion App `:8090`) |
| :--- | :--- | :--- |
| **Core Runtime & Bundler** | React `19.2.6`, TypeScript `6.0.2`, Vite `8.3.8`, React Router `7.16.0` | Expo SDK `~58.0.26`, React Native `0.88.1`, React `19.3.0`, TypeScript `6.0.3` |
| **Styling & Design System** | Tailwind CSS `4.3.0` (`@tailwindcss/vite`), `shadcn` `4.13.0`, `radix-ui` `1.6.2`, `@astryxdesign/core` `0.7.16`, `lucide-react` `1.17.0` | Native StyleSheet + Reanimated `4.7.1`, Gesture Handler `3.3.0`, `lucide-react-native` `1.62.0`, `expo-image` |
| **State & Server Cache** | TanStack Query `5.100.14`, Zustand `5.0.14` + Immer `11.1.15`, React Hook Form `7.77.0` + Zod `4.4.3` | Zustand `5.0.14`, `expo-secure-store` (RS256 token storage), `expo-auth-session` |
| **Rich Editing & Realtime** | TipTap `3.35.0` + Yjs `13.6.33` CRDT, `@stomp/stompjs` `7.3.0` WebSockets, Agora RTC `4.24.9` | Yjs `13.6.33` (`y-protocols`), `expo-notifications` (FCM push), `react-native-vision-camera` `5.2.4` |
| **Scheduling, Charts & Motion** | FullCalendar `6.1.21` (`daygrid`/`timegrid`/`interaction`), Recharts `3.10.1`, Motion `12.43.0` + GSAP `3.15.0`, `qrcode.react` `4.2.0` (SePay VietQR & 2FA TOTP) | `react-native-qrcode-svg`, `expo-video`, `expo-local-authentication` |
| **Internationalization & QA** | `i18next` `26.3.6` + `react-i18next` `17.0.11` (`vi.json` + `en.json` parity), Playwright `1.62.1` + Vitest `3.2.4` | Bilingual locale dictionaries, Jest `30.5.2` + `@testing-library/react-native` `14.1.0` |

---

## 3. Historical V1 Prototype Deliverables (Archived)

Early V1 Figma task reports from the legacy `Uibrandhubs` prototype (`DA-E08-01` 7-screen overview, `DA-E08-02` initial token report, `DA-E08-03` V1 user flows, and `install-animate-report.md`) have been consolidated into the [V1 Legacy Archive](../archive/v1-legacy/README.md) so `docs/wireframe/` contains only active V2/V3 architecture documents.
