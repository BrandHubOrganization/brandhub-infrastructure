# Package simplification

User instruction: 2026-10-16. One Workspace has one Campaign; quantities are total per package.

## Confirmed scope

- Display services as Bài đăng mạng xã hội, Event planning, Livestream, Báo điện tử, Workshop.
- Labels do not expand scope: press remains partner recommendations; workshop remains Meet link/survey; event remains plan delivery.
- Improve multiline description and acceptance input, with associated labels and semantic theme tokens.
- Retire package_type/offering_model from new UI and contract after compatibility work. Preserve legacy data and approved snapshots.
- Client cannot edit service, unit or maxChanges. Preserve version checks and both-side approval reset.
- Vietnamese/English keys remain parallel. No shared UI or other members' modules changed.

## Confirmed details

Budget and duration are optional, but when supplied must be positive (duration integer weeks).
Units: SOCIAL_POST=bài; EVENT_PLANNING=sự kiện; LIVESTREAM_PREPARATION=buổi;
PRESS_RECOMMENDATION=danh sách đề xuất; WORKSHOP_SUPPORT=buổi.
New API/entity/schema have no classification fields. Legacy request keys are ignored;
Java compatibility constructors accept old parameters without storing them.
Both financial fields remain optional. Existing JSON snapshots are not rewritten;
legacy monthly snapshot guards remain to prevent accidental conversion to total quantities.
Old approved units remain unchanged. Client proposals preserve those units.
