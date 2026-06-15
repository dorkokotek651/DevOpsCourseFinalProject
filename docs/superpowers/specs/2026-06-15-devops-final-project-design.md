# MeTA DevOps Final Project — CI/CD Pipeline Design

**Date:** 2026-06-15
**Group:** Moshe Tal, Shoham Fellner, Amit Reich, Omri Kadmon, Dor Kokotek
**GitHub:** https://github.com/moshetal/DevOpsCourseFinalProject
**Deadline:** 15/06/2026 midnight

## Goal

Deliver the existing `index.jsp` ("Compliment-o-Roast") app from development to production
through a single CI/CD story: orchestrate, deploy, automate, monitor, and performance-test.
Tests use **Playwright** (in place of Selenium IDE), generated with the Playwright MCP against
the running app.

## Environment (detected)

- Apache **Tomcat 10.1.34** at `C:\apache-tomcat-10.1.34` (webapps: `C:\apache-tomcat-10.1.34\webapps`)
- **Jenkins** installed and running
- **Java 21**, **Node v20.19.0**, **npm 10.8.2**
- **Maven not installed** → use the Maven Wrapper (`mvnw`), so Jenkins calls `./mvnw` with no global install
- **Gatling** not installed → provided via the Gatling Maven plugin

## Repository structure

```
DevOpsCourseFinalProject/
├── index.jsp                      # the app (input box, 2 buttons, link — satisfies #1)
├── Dockerfile                     # FROM tomcat:10.1-jdk21 — for free hosting (#5)
├── tests/                         # Playwright (replaces Selenium IDE)
│   ├── package.json
│   ├── playwright.config.ts       # JUnit reporter + base URL via env
│   └── e2e/compliment-roast.spec.ts
├── gatling/                       # Gatling Maven (Java)
│   ├── pom.xml
│   ├── mvnw / mvnw.cmd / .mvn/wrapper/
│   └── src/test/java/computerdatabase/   # (default Gatling Java package layout)
│       ├── MaxLimitSimulation.java
│       ├── LoadSimulation.java
│       └── StressSimulation.java
├── jenkins/
│   ├── Jenkinsfile.deploy         # Git → Tomcat (the main pipeline, #4)
│   ├── Jenkinsfile.tests          # trigger Playwright (#7)
│   ├── Jenkinsfile.monitor        # ping every 5 min (#6)
│   └── Jenkinsfile.gatling        # parameterized max/load/stress (#8–10)
└── docs/
    ├── README.md                  # full runbook / setup
    └── DELIVERABLES.md            # checklist mapping all 12 email items (a–l)
```

## Components

### 1. The app (#1) — done
`index.jsp` has one input (`name`), two buttons (Compliment/Roast), and a link (GitHub).
Server-side it picks a random compliment/roast and HTML-escapes input. No changes needed.

### 2. Deploy to Tomcat (#3, #4)
- Production context path (folder under `webapps/`) includes the group names:
  **`compliment-tal-fellner-reich-kadmon-kokotek`**
  → `http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/`
- `jenkins/Jenkinsfile.deploy`: checkout from GitHub → create/clean the webapps folder →
  copy `index.jsp` in → smoke-check the URL returns HTTP 200. This is the job the examiner
  triggers after a live code change (defense step D).

### 3. Playwright tests (#7) — 5 validations
Generated against the running app via Playwright MCP, then committed as `compliment-roast.spec.ts`.
Mix of assert (hard/blocking) and verify (soft/expect.soft), positive and negative:

1. **Positive · assert** — page loads: title, input, and both buttons present.
2. **Positive · assert** — type name → click Compliment → result box appears, contains the
   name, has compliment (green) styling.
3. **Positive · assert** — type name → click Roast → result contains the name, roast (red) styling.
4. **Negative · assert** — submit empty name → no result box rendered (validates the JSP guard).
5. **Verify · soft** — GitHub link present + correct href, footer/badge text present (non-blocking).

Reporter: JUnit XML (`results.xml`) so Jenkins shows pass/fail. The `.spec.ts` is the modern
equivalent of a Selenium `.side` file. Base URL is configurable via `BASE_URL` env var so the
same suite runs against localhost or the live Render URL.

**Validation rationale (for deliverable g):**
- Positive tests confirm the core feature works (compliment & roast produce correct output).
- The negative test confirms invalid input (empty name) is correctly rejected — guards against regressions in the input check.
- `assert` (hard) is used for must-pass behavior that should stop the run; `verify` (soft) is used for secondary UI elements (link/footer) where we want the full picture even if one fails.

### 4. Gatling — Maven (Java) (#8, #9, #10)
Same user journey in all three: `GET /` → `POST action=compliment` → `POST action=roast`.
- **MaxLimitSimulation** — ramp concurrent users upward until response time / error rate
  degrades; the inflection point is the reported max limit (#8, deliverable j).
- **LoadSimulation** — steady, realistic concurrency held for 5 minutes (#9).
- **StressSimulation** — aggressive ramp sustained for 5 minutes (#10).
Run via `./mvnw gatling:test -Dgatling.simulationClass=<FQCN>`. Each run produces an
`index.html` report (exported to PDF for deliverable l) and a CMD summary (deliverable k).

### 5. Jenkins (single CI/CD story, several triggerable jobs)
Recommended layout — one deploy pipeline plus small independently-triggerable jobs, because the
assignment explicitly wants separate jobs (monitor every 5 min, tests, each Gatling run) and
separate jobs produce cleaner screenshots for the deliverables:
- **Deploy** (`Jenkinsfile.deploy`) — Git → Tomcat, the main pipeline.
- **Playwright-Tests** (`Jenkinsfile.tests`) — `npm ci` + `npx playwright test`, publishes JUnit.
- **Monitor** (`Jenkinsfile.monitor`) — cron `H/5 * * * *`; curls the URL and/or hits the
  UptimeRobot API as the 5-minute heartbeat (#6).
- **Gatling** (`Jenkinsfile.gatling`) — `TEST_TYPE` parameter (MAX/LOAD/STRESS) selecting the
  simulation; archives the HTML report.
README documents which Jenkins plugins to install (Git, Pipeline, JUnit, HTML Publisher).

### 6. Live deployment — free hosting (#5 bonus)
`Dockerfile` based on `tomcat:10.1-jdk21` copying `index.jsp` into the webapps folder.
Connect the GitHub repo to **Render** (free tier, auto-deploys on push, Docker build) → public
HTTPS URL. Cold-start on idle is mitigated by the 5-minute UptimeRobot ping. README has the
step-by-step.

### 7. Monitoring (#6)
**UptimeRobot** (free) HTTP monitor on the public Render URL (or localhost during demo), 5-minute
interval. The Jenkins Monitor job is the scheduled trigger/heartbeat. README documents creating
the monitor and capturing the "passed" screenshot.

## Deliverables mapping (email items a–l)
`docs/DELIVERABLES.md` will track all 12 items: jsp file (a), GitHub screenshot (b), Tomcat URL
screenshot (c), repo link (d), monitor name + screenshot (e), Playwright spec as the test file
(f), test pass screenshot + validation explanation (g), HAR scenario in words (h), HAR file (i),
max-limit explanation (j), 3 Gatling CMD screenshots (k), 3 Gatling PDF reports (l).

## Out of scope / user-performed
- Creating accounts (GitHub already exists, Render, UptimeRobot).
- Installing Jenkins plugins and creating the jobs in the Jenkins UI (documented, not automated).
- Capturing the screenshots and exporting Gatling PDFs (manual deliverables).
- Recording the HAR file (manual via browser DevTools; scenario documented).

## Open items resolved
- GitHub remote: `https://github.com/moshetal/DevOpsCourseFinalProject`
- Tomcat folder: `compliment-tal-fellner-reich-kadmon-kokotek`
- Live host: Render via Dockerfile
