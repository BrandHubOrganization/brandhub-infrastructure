# Sprint Files Index

Detailed breakdown of all 16 sprints. Main project plan at `../BrandHub_Project_Plan.md`.
AI Parallel Track iterations at `../iterations/`.

## Sprint Files

| File | Sprint | Timeline | Phase |
|---|---|---|---|
| [Sprint_01_Project_Kickoff.md](Sprint_01_Project_Kickoff.md) | Sprint 1 | Weeks 1–2 (May 16–29) | Initiation |
| [Sprint_02_Requirements_Architecture.md](Sprint_02_Requirements_Architecture.md) | Sprint 2 | Weeks 3–4 (May 30–Jun 12) | Documentation |
| [Sprint_03_Database_API_UI_Design.md](Sprint_03_Database_API_UI_Design.md) | Sprint 3 | Weeks 5–6 (Jun 16–30) | Design |
| [Sprint_04_Infrastructure_CICD_Gateway.md](Sprint_04_Infrastructure_CICD_Gateway.md) | Sprint 4 | Weeks 7–8 (Jul 1–14) | Infrastructure |
| [Sprint_05_Authentication_RBAC.md](Sprint_05_Authentication_RBAC.md) | Sprint 5 | Weeks 9–10 (Jul 15–28) | Backend Core |
| [Sprint_06_Workspace_Client_Subscription.md](Sprint_06_Workspace_Client_Subscription.md) | Sprint 6 | Weeks 11–12 (Jul 29–Aug 11) | Backend Core |
| [Sprint_07_Social_OAuth_Token_Management.md](Sprint_07_Social_OAuth_Token_Management.md) | Sprint 7 | Weeks 13–14 (Aug 12–25) | Social Integration |
| [Sprint_08_Publisher_Service.md](Sprint_08_Publisher_Service.md) | Sprint 8 | Weeks 15–16 (Aug 26–Sep 8) | Social Integration |
| [Sprint_09_AI_Service_Wiring.md](Sprint_09_AI_Service_Wiring.md) | Sprint 9 | Weeks 17–18 (Sep 9–22) | AI Pipeline |
| [Sprint_10_Content_Requests_Calendar.md](Sprint_10_Content_Requests_Calendar.md) | Sprint 10 | Weeks 19–20 (Sep 23–Oct 6) | Content Workflow |
| [Sprint_11_Approval_Workflow_Publishing.md](Sprint_11_Approval_Workflow_Publishing.md) | Sprint 11 | Weeks 21–22 (Oct 7–20) | Content Workflow |
| [Sprint_12_Design_System_Core_Pages.md](Sprint_12_Design_System_Core_Pages.md) | Sprint 12 | Weeks 23–24 (Oct 21–Nov 3) | Frontend |
| [Sprint_13_Client_Portal_Analytics_Notifications.md](Sprint_13_Client_Portal_Analytics_Notifications.md) | Sprint 13 | Weeks 25–26 (Nov 4–17) | Frontend |
| [Sprint_14_Mobile_App.md](Sprint_14_Mobile_App.md) | Sprint 14 | Weeks 27–28 (Nov 18–Dec 1) | Mobile |
| [Sprint_15_Testing_Bug_Fixes.md](Sprint_15_Testing_Bug_Fixes.md) | Sprint 15 | Weeks 29–30 (Dec 2–15) | Testing |
| [Sprint_16_Deployment_Docs_Presentation.md](Sprint_16_Deployment_Docs_Presentation.md) | Sprint 16 | Weeks 31–32 (Dec 16–29) | Launch |

## AI Parallel Track Alignment

| Sprint | AI Iteration running concurrently |
|---|---|
| Sprint 5–6 | AI Iteration 1 — Research & Evaluation |
| Sprint 7–8 | AI Iteration 2 — RAG, LLM & Trends |
| Sprint 9–10 | AI Iteration 3 — Image, Ambassador & Composition |
| Sprint 11–12 | AI Iteration 4 — Video, Integration & Documentation |

## Key Issues Found During Review

| Sprint | Issue | Status |
|---|---|---|
| Sprint 10 | Epics E25–E27 not used (gap in numbering after E24) | Intentional — reserved for future scope |
| Sprint 2 | UC numbering assumes 10 UCs per role — adjust if actual count differs | Review in Sprint 2 |
| Sprint 7 | Zalo OA token TTL is 1h — requires dedicated 45-min refresh job separate from nightly job | See Sprint 7 notes |
| Sprint 11 | RabbitMQ delayed message requires `rabbitmq_delayed_message_exchange` plugin — must enable in docker-compose | Add to docker-compose in Sprint 4 |
| Sprint 16 | EC2 t3.medium may be insufficient if all AI models run locally — InstantID requires GPU | Use Stability AI API / Replicate API for image generation, not local GPU |
