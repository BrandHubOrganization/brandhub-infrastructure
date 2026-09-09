# Sprint 14 — Mobile App

**Timeline:** Weeks 27–28 (Nov 18–Dec 1, 2026)
**Jira:** DA Sprint 14
**Phase:** Phase 7 — Testing, Deployment & Final Report
**Goal:** Build the React Native mobile app with core screens (auth, dashboard, calendar, approval) and push notification support via FCM.

---

## Overview

| Epic | Title | Owner |
|---|---|---|
| E40 | Mobile App Core | Phước |
| E41 | Mobile Notifications | Phước, Trung |

> 🔀 **Rebalance sau Sprint 4:** E40–E41 chuyển từ Lộc sang Phước. Chi tiết: [Rebalance Log](../../Jira_Status_Audit_2026-07-11.md#rebalance-log--sau-sprint-4).

**Deliverables by end of Sprint 14:**
- React Native app runs on iOS and Android (Expo)
- Auth screens: Login, Register, Forgot Password
- Dashboard screen (simplified overview)
- Calendar screen (read-only post calendar)
- Approval screen for BRAND_CLIENT
- Offline draft mode (save to AsyncStorage, sync on reconnect)
- FCM push notifications working on both platforms
- Native camera + media gallery upload

---

## EPIC E40 — Mobile App Core

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E40-01 | Set up React Native project with Expo, navigation (React Navigation v6) | Phước (Publisher) | 🔴 Critical |
| DA-E40-02 | Build Auth screens (Login, Register, Forgot Password) | Phước (Publisher) | 🔴 Critical |
| DA-E40-03 | Build Dashboard screen (simplified overview) | Phước (Publisher) | 🔴 Critical |
| DA-E40-04 | Build Calendar screen (calendar view, post status) | Phước (Publisher) | 🟡 High |
| DA-E40-05 | Build Approval screen for BRAND_CLIENT (view preview, approve/reject) | Phước (Publisher) | 🔴 Critical |
| DA-E40-06 | Implement offline draft mode (save draft to AsyncStorage when offline, sync when back online) | Phước (Publisher) | 🟡 High |

**Navigation structure (DA-E40-01):**
```
Stack:
  AuthStack: Login, Register, ForgotPassword
  MainTabs (authenticated):
    Tab 1: Dashboard
    Tab 2: Calendar
    Tab 3: Tasks (CONTENT_CREATOR) / Approvals (BRAND_CLIENT)
    Tab 4: Notifications
    Tab 5: Profile
```

**Calendar screen (DA-E40-04):**
- Use `react-native-calendars` library
- Show dots on dates with scheduled posts
- Tap date → list of posts for that day
- Tap post → PostDetail screen (read-only)

**Offline draft (DA-E40-06):**
- Store draft in `AsyncStorage` with key `drafts:{userId}:{tempId}`
- On reconnect: `NetInfo.addEventListener` detects connection → sync pending drafts via API
- Show "Offline" banner when no connection

---

## EPIC E41 — Mobile Notifications

| Task ID | Description | Assignee | Priority |
|---|---|---|---|
| DA-E41-01 | Integrate Firebase Cloud Messaging (FCM) for push notifications | Phước (Publisher) | 🔴 Critical |
| DA-E41-02 | Set up FCM server-side (send notification when events occur in business-service) | Trung (Leader) | 🔴 Critical |
| DA-E41-03 | Build Notification screen (list notifications, deep link on tap) | Phước (Publisher) | 🟡 High |
| DA-E41-04 | Integrate native camera + media gallery upload | Phước (Publisher) | 🟡 High |

**FCM setup (DA-E41-01):**
- Use `@react-native-firebase/messaging`
- Request permission on first launch
- Save FCM token to user profile via `PUT /api/v1/users/me/fcm-token`
- Handle foreground messages (show in-app banner) and background/quit state (system notification)

**FCM server-side (DA-E41-02):**
- business-service: on notification creation, if user has fcmToken → call FCM HTTP API v1
- FCM payload: `{title, body, data: {type: "POST_PUBLISHED", postId: "..."}}`
- Deep link data: used by mobile to navigate to correct screen on tap

**Camera/gallery upload (DA-E41-04):**
- Use `expo-image-picker` for gallery
- Use `expo-camera` for camera
- Upload selected file to `POST /api/v1/media/upload` → S3 → return URL
- Used in Content Editor (CONTENT_CREATOR) and Approval screen (BRAND_CLIENT can upload reference)

**Deep link navigation on notification tap:**
| Notification type | Navigate to |
|---|---|
| POST_PUBLISHED | Calendar → that date |
| TASK_ASSIGNED | Tasks → that request |
| APPROVAL_NEEDED | Approvals → that post |
| TOKEN_EXPIRING | Profile → Social Accounts |

---

## Sprint 14 Checklist

- [ ] Expo app runs on iOS simulator and Android emulator
- [ ] Login screen: email/password works, redirects to Dashboard
- [ ] Google OAuth button redirects to browser OAuth flow
- [ ] Register screen: creates account
- [ ] Forgot Password: sends email
- [ ] Dashboard: shows total posts, success rate, recent activity
- [ ] Calendar: shows post dots, tap date shows post list
- [ ] Approval screen (BRAND_CLIENT): approve/reject works
- [ ] Offline draft: save draft while offline, sync on reconnect
- [ ] FCM permission requested on first launch
- [ ] Push notification received when post published (test on real device)
- [ ] Tap notification: navigates to correct screen
- [ ] Notification screen: list + mark as read
- [ ] Camera/gallery: select image → upload to S3 → URL returned
