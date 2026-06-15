# Final Project — Email Deliverables Checklist

**Send to:** mosh.mta2@gmail.com
**Subject:** `Final Exercise from: Moshe Tal, Shoham Fellner, Amit Reich, Omri Kadmon, Dor Kokotek`
**Public repo:** https://github.com/dorkokotek651/DevOpsCourseFinalProject

All 12 items (a–l) and where each artifact now lives in the repo.

| # | Deliverable | Artifact |
|---|-------------|----------|
| a | The JSP file | `index.jsp` |
| b | GitHub screenshot | `docs/screenshots/github-repo.png` |
| c | App in Tomcat (show URL) | `docs/screenshots/app-tomcat-8081.png` — URL `http://localhost:8081/compliment-tal-fellner-reich-kadmon-kokotek/` (for the email, you may want a shot that also shows the browser address bar) |
| d | Public repo link | https://github.com/dorkokotek651/DevOpsCourseFinalProject |
| e | Monitor + "Up" screenshot | **UptimeRobot**, HTTP monitor on the Render URL, 5-min interval, status "Up". Screenshot is in the chat (login-gated, so not regenerable to a file here) — save it from there |
| f | Test file (replaces .side) | `tests/e2e/compliment-roast.spec.ts` (Playwright) |
| g | Test pass + validation explanation | `docs/screenshots/playwright-report.png` (5 passed). Validation rationale: see README §2 — positive (1–3) prove compliment/roast work; negative (4) asserts the "Please enter a name first." error; hard `assert` for must-pass behavior, soft `verify` for the link/badge |
| h | HAR scenario in words | load page → type name → Compliment → type name → Roast (README §7) |
| i | The HAR file | `docs/compliment-roast.har` |
| j | Max limit + why | `docs/gatling-cmd-summaries.txt` (bottom). Ramped to 200 req/s, 36,180 requests, 0 errors, p99 = 3 ms → limit is above 200 req/s on this hardware (pure-CPU JSP, no DB/IO) |
| k | 3 Gatling CMD summaries | `docs/gatling-cmd-summaries.txt` (exact console output) + `docs/screenshots/gatling-{max-limit,load,stress}.png` |
| l | 3 Gatling PDFs (graphs) | `docs/gatling-reports/gatling-{max-limit,load,stress}.pdf` |

## Bonus #5 (+10) — done
Live public app on Render: https://devopscoursefinalproject.onrender.com/ , monitored by UptimeRobot.
The 5 Playwright tests also pass against this live URL.

## Why the Gatling graphs look flat (for the email)
Arrival rates stayed within the app's capacity, so latency stays ~1 ms and error rate is 0% for the
whole run — a healthy, unsaturated system. The max-limit ramp confirms the ceiling is higher than the
200 req/s tested.

## Jenkins (CI/CD, assignment #4/#6/#7/#8–10)
4 Pipeline jobs at http://localhost:8080 — Deploy, Playwright-Tests, Monitor (5-min cron), Gatling
(MAX/LOAD/STRESS) — all verified green. Pipelines-as-code in `jenkins/Jenkinsfile.*`.
