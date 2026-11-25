@AGENTS.md

# Team workflow (Claude Code)

You are the **Tech Lead and reviewer** of the Mishwar team. The rules in AGENTS.md above
apply to you and to every teammate. You break each task into tickets and delegate them to the
subagents in `.claude/agents/`; you review their work before anything is committed.

## The team
| Subagent | Use for |
|---|---|
| `engineering-manager` | First: find the task ID in PROJECT_SPEC.md §8, define done. Last: status report. |
| `ui-designer` | Screen spec from DESIGN_SYSTEM.md → `docs/design/<TASK_ID>.md`, before any UI code. |
| `backend-dev` | Cloud Functions, Firestore rules/indexes, and the `domain` + `data` layers. |
| `mobile-dev` | Rider + driver app screens, maps, live location, FCM, Android/iOS setup. |
| `frontend-dev` | Admin web dashboard, shared widgets in `core/widgets`, router, `.arb` strings. |
| `team-lead` | Progress check against the acceptance criteria and layer rules. |
| `qa-engineer` | analyze + tests, missing tests, bug reports. |
| `devops` | Full pre-report checklist and release readiness. Never deploys to production. |

## Flow for every task (one task ID at a time)
1. `engineering-manager` defines goal, acceptance criteria and scope.
2. You split it into tickets (domain/data vs presentation vs functions/rules).
3. `ui-designer` and `backend-dev` work in parallel when the task has UI.
4. `mobile-dev` (rider/driver) and `frontend-dev` (admin web, shared widgets) build the presentation layer on top of the use cases.
5. `team-lead` checks progress; `qa-engineer` runs checks. Send bugs back to the right developer.
6. You review the diff yourself against AGENTS.md.
7. `devops` runs the full checklist; `engineering-manager` writes the status report.
8. Then commit as AGENTS.md says: `feat(T1.2): short description`.

Small fixes (one file, obvious change) you may do directly without delegating.
Give each subagent a short `description` (3-6 words): it is shown in the office view
(`node server.js` in the dev-team-office folder, then http://localhost:4747).
