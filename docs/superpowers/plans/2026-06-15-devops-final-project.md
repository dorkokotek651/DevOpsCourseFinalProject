# MeTA DevOps Final Project Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a single CI/CD pipeline that deploys the `index.jsp` "Compliment-o-Roast" app to Tomcat, tests it with Playwright, performance-tests it with Gatling, monitors it, and can be published to a free host (Render).

**Architecture:** The existing `index.jsp` is deployed to a named Tomcat webapps folder by a Jenkins deploy pipeline. Playwright (replacing Selenium IDE) provides 5 functional validations. Gatling (Maven/Java, via Maven Wrapper) provides max-limit/load/stress simulations. Jenkins runs each concern as an independently-triggerable job. A `Dockerfile` enables free hosting on Render for the public-IP bonus.

**Tech Stack:** JSP on Tomcat 10.1.34, Java 21, Node 20 + Playwright, Gatling 3.13 via gatling-maven-plugin 4.x + Maven Wrapper, Jenkins (Windows `bat` agent), Docker (Render build), UptimeRobot.

**Key constants:**
- App folder / context path: `compliment-tal-fellner-reich-kadmon-kokotek`
- Local URL: `http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/`
- Tomcat webapps: `C:\apache-tomcat-10.1.34\webapps`
- GitHub: `https://github.com/moshetal/DevOpsCourseFinalProject` (branch `devops-final-project`)
- Group: Moshe Tal, Shoham Fellner, Amit Reich, Omri Kadmon, Dor Kokotek

---

### Task 1: Deploy the app to local Tomcat (needed before Playwright/Gatling can run)

**Files:**
- Read: `index.jsp`
- Deploy target: `C:\apache-tomcat-10.1.34\webapps\compliment-tal-fellner-reich-kadmon-kokotek\index.jsp`

- [ ] **Step 1: Check whether Tomcat is running on 8080**

Run (PowerShell):
```powershell
(Invoke-WebRequest -UseBasicParsing http://localhost:8080/ -TimeoutSec 5).StatusCode
```
Expected: `200`. If it errors/refuses, start Tomcat:
```powershell
Start-Process "C:\apache-tomcat-10.1.34\bin\startup.bat"
```
Then wait ~10s and re-check.

- [ ] **Step 2: Copy the app into a named webapps folder**

Run (PowerShell):
```powershell
$dst = "C:\apache-tomcat-10.1.34\webapps\compliment-tal-fellner-reich-kadmon-kokotek"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item -Force "index.jsp" "$dst\index.jsp"
```
Expected: no error; file present.

- [ ] **Step 3: Verify the app responds 200 and renders the title**

Run (PowerShell):
```powershell
$r = Invoke-WebRequest -UseBasicParsing "http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/"
$r.StatusCode
$r.Content -match "Compliment-o-Roast"
```
Expected: `200` and `True`.

- [ ] **Step 4: No commit** (this task only deploys; nothing changed in the repo).

---

### Task 2: Scaffold the Playwright test project

**Files:**
- Create: `tests/package.json`
- Create: `tests/playwright.config.ts`
- Create: `.gitignore`

- [ ] **Step 1: Create `.gitignore` at repo root**

```gitignore
# Node / Playwright
tests/node_modules/
tests/playwright-report/
tests/test-results/
tests/results.xml
# Gatling / Maven
gatling/target/
.mvn/wrapper/maven-wrapper.jar
# OS / IDE
.DS_Store
*.log
```

- [ ] **Step 2: Create `tests/package.json`**

```json
{
  "name": "compliment-roast-tests",
  "version": "1.0.0",
  "description": "Playwright functional tests for the Compliment-o-Roast app",
  "scripts": {
    "test": "playwright test"
  },
  "devDependencies": {
    "@playwright/test": "^1.49.0"
  }
}
```

- [ ] **Step 3: Create `tests/playwright.config.ts`**

```ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  reporter: [
    ['list'],
    ['junit', { outputFile: 'results.xml' }],
    ['html', { open: 'never' }],
  ],
  use: {
    baseURL:
      process.env.BASE_URL ||
      'http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }],
});
```

- [ ] **Step 4: Install dependencies and the browser**

Run (PowerShell, from repo root):
```powershell
cd tests; npm install; npx playwright install chromium; cd ..
```
Expected: installs `@playwright/test` and the Chromium browser with no errors.

- [ ] **Step 5: Commit**

```bash
git add .gitignore tests/package.json tests/package-lock.json tests/playwright.config.ts
git commit -m "Scaffold Playwright test project"
```

---

### Task 3: Generate & write the 5 Playwright validations (via Playwright MCP), run them

**Files:**
- Create: `tests/e2e/compliment-roast.spec.ts`

- [ ] **Step 1: Explore the running app with Playwright MCP to confirm selectors**

Use the Playwright MCP tools (`browser_navigate` to the local URL, `browser_snapshot`) to confirm:
the input is `#nameInput`, the buttons have accessible names matching `/Compliment/` and `/Roast/`,
the result container is `.result-box` with modifier classes `result-compliment` / `result-roast`,
the result text is in `.result-text`, the GitHub link is `.footer a`, the badge is `.badge`.
Adjust the spec below only if the live snapshot differs.

- [ ] **Step 2: Write `tests/e2e/compliment-roast.spec.ts`**

```ts
import { test, expect } from '@playwright/test';

// Five validations mixing positive/negative and assert(hard)/verify(soft).
test.describe('Compliment-o-Roast', () => {
  // 1. Positive · assert — the page and its controls load.
  test('page loads with input and both buttons', async ({ page }) => {
    await page.goto('./');
    await expect(page).toHaveTitle('Compliment-o-Roast');
    await expect(page.locator('#nameInput')).toBeVisible();
    await expect(page.getByRole('button', { name: /Compliment/ })).toBeVisible();
    await expect(page.getByRole('button', { name: /Roast/ })).toBeVisible();
  });

  // 2. Positive · assert — Compliment returns a green result containing the name.
  test('compliment produces a green result containing the name', async ({ page }) => {
    await page.goto('./');
    await page.locator('#nameInput').fill('Dor');
    await page.getByRole('button', { name: /Compliment/ }).click();
    const box = page.locator('.result-box');
    await expect(box).toBeVisible();
    await expect(box).toHaveClass(/result-compliment/);
    await expect(box.locator('.result-text')).toContainText('Dor');
  });

  // 3. Positive · assert — Roast returns a red result containing the name.
  test('roast produces a red result containing the name', async ({ page }) => {
    await page.goto('./');
    await page.locator('#nameInput').fill('Amit');
    await page.getByRole('button', { name: /Roast/ }).click();
    const box = page.locator('.result-box');
    await expect(box).toBeVisible();
    await expect(box).toHaveClass(/result-roast/);
    await expect(box.locator('.result-text')).toContainText('Amit');
  });

  // 4. Negative · assert — submitting an empty name yields no result box (JSP guard).
  test('empty name produces no result', async ({ page }) => {
    await page.goto('./');
    await page.getByRole('button', { name: /Compliment/ }).click();
    await expect(page.locator('.result-box')).toHaveCount(0);
  });

  // 5. Verify · soft — secondary UI: GitHub link + badge are present (non-blocking).
  test('github link and badge are present', async ({ page }) => {
    await page.goto('./');
    await expect.soft(page.locator('.footer a')).toHaveAttribute('href', /github\.com/);
    await expect.soft(page.locator('.badge')).toContainText('MTA DevOps Final Project');
  });
});
```

- [ ] **Step 3: Run the suite against the local app**

Run (PowerShell):
```powershell
cd tests; $env:BASE_URL="http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/"; npx playwright test; cd ..
```
Expected: `5 passed`. If a selector mismatch fails, fix the spec to match the live snapshot from Step 1 and re-run.

- [ ] **Step 4: Commit**

```bash
git add tests/e2e/compliment-roast.spec.ts
git commit -m "Add 5 Playwright validations (positive/negative, assert/verify)"
```

---

### Task 4: Add the Dockerfile for free hosting (Render)

**Files:**
- Create: `Dockerfile`
- Create: `.dockerignore`

- [ ] **Step 1: Create `Dockerfile`**

```dockerfile
# Free-hosting image for Render. Serves index.jsp as the ROOT app so the
# public URL is the bare domain (clean for monitoring).
FROM tomcat:10.1-jdk21-temurin

# Replace the default ROOT app with our JSP.
RUN rm -rf /usr/local/tomcat/webapps/ROOT
RUN mkdir -p /usr/local/tomcat/webapps/ROOT
COPY index.jsp /usr/local/tomcat/webapps/ROOT/index.jsp

EXPOSE 8080
CMD ["catalina.sh", "run"]
```

- [ ] **Step 2: Create `.dockerignore`**

```dockerignore
tests/
gatling/
jenkins/
docs/
*.pdf
.git/
```

- [ ] **Step 3: (Optional) Verify the image builds locally — only if Docker is installed**

Run (PowerShell):
```powershell
docker --version
docker build -t compliment-roast .
docker run -d -p 8081:8080 --name cr-test compliment-roast
Start-Sleep 8
(Invoke-WebRequest -UseBasicParsing http://localhost:8081/).Content -match "Compliment-o-Roast"
docker rm -f cr-test
```
Expected: build succeeds and the match is `True`. If Docker is not installed, skip — Render builds the image itself; note this in the commit message.

- [ ] **Step 4: Commit**

```bash
git add Dockerfile .dockerignore
git commit -m "Add Dockerfile for free hosting on Render"
```

---

### Task 5: Set up the Gatling Maven project with the Maven Wrapper

**Files:**
- Create: `gatling/pom.xml`
- Create (generated): `gatling/mvnw`, `gatling/mvnw.cmd`, `gatling/.mvn/wrapper/maven-wrapper.properties`

- [ ] **Step 1: Create `gatling/pom.xml`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.meta</groupId>
  <artifactId>compliment-roast-gatling</artifactId>
  <version>1.0.0</version>
  <packaging>jar</packaging>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <maven.compiler.release>21</maven.compiler.release>
    <gatling.version>3.13.5</gatling.version>
    <gatling-maven-plugin.version>4.9.6</gatling-maven-plugin.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>io.gatling.highcharts</groupId>
      <artifactId>gatling-charts-highcharts</artifactId>
      <version>${gatling.version}</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>io.gatling</groupId>
        <artifactId>gatling-maven-plugin</artifactId>
        <version>${gatling-maven-plugin.version}</version>
      </plugin>
    </plugins>
  </build>
</project>
```

- [ ] **Step 2: Get a usable Maven to bootstrap the wrapper (no global install)**

Run (PowerShell) — download a portable Maven into a temp tools dir:
```powershell
$tools = "$env:TEMP\apache-maven-3.9.9"
if (-not (Test-Path $tools)) {
  $zip = "$env:TEMP\maven.zip"
  Invoke-WebRequest -UseBasicParsing "https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip" -OutFile $zip
  Expand-Archive -Force $zip "$env:TEMP"
}
& "$tools\bin\mvn.cmd" -version
```
Expected: prints `Apache Maven 3.9.9`. (If the dlcdn mirror is unavailable, use `https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip`.)

- [ ] **Step 3: Generate the Maven Wrapper inside `gatling/`**

Run (PowerShell, from repo root):
```powershell
& "$env:TEMP\apache-maven-3.9.9\bin\mvn.cmd" -f gatling/pom.xml -N wrapper:wrapper -Dmaven=3.9.9
```
Expected: creates `gatling/mvnw`, `gatling/mvnw.cmd`, `gatling/.mvn/wrapper/`.

- [ ] **Step 4: Verify the wrapper works**

Run (PowerShell):
```powershell
cd gatling; .\mvnw.cmd -version; cd ..
```
Expected: downloads Maven 3.9.9 on first run and prints the version.

- [ ] **Step 5: Commit**

```bash
git add gatling/pom.xml gatling/mvnw gatling/mvnw.cmd gatling/.mvn
git commit -m "Set up Gatling Maven project with Maven Wrapper"
```

---

### Task 6: Write the three Gatling simulations and verify they compile

**Files:**
- Create: `gatling/src/test/java/simulations/MaxLimitSimulation.java`
- Create: `gatling/src/test/java/simulations/LoadSimulation.java`
- Create: `gatling/src/test/java/simulations/StressSimulation.java`

- [ ] **Step 1: Create `MaxLimitSimulation.java`**

```java
package simulations;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.time.Duration;

/**
 * Find the application's max limit: ramp open arrivals from 1 to 200 req/s over
 * 2 minutes. The point where response time / error rate climbs sharply is the
 * max limit. The assertion documents the SLO we consider "still healthy".
 */
public class MaxLimitSimulation extends Simulation {

  private static final String BASE_URL =
      System.getProperty("baseUrl",
          System.getenv().getOrDefault("BASE_URL",
              "http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek"));

  HttpProtocolBuilder httpProtocol =
      http.baseUrl(BASE_URL)
          .acceptHeader("text/html,application/xhtml+xml")
          .userAgentHeader("Gatling-MaxLimit");

  ScenarioBuilder scn =
      scenario("Compliment-Roast journey")
          .exec(http("Get home").get("/").check(status().is(200)))
          .pause(1)
          .exec(http("Compliment").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "compliment")
              .check(status().is(200)))
          .pause(1)
          .exec(http("Roast").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "roast")
              .check(status().is(200)));

  {
    setUp(
        scn.injectOpen(
            rampUsersPerSec(1).to(200).during(Duration.ofMinutes(2))))
        .protocols(httpProtocol)
        .assertions(global().responseTime().percentile3().lt(2000));
  }
}
```

- [ ] **Step 2: Create `LoadSimulation.java`**

```java
package simulations;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.time.Duration;

/**
 * Load test: a steady, realistic 20 arrivals/second held for 5 minutes.
 * Represents expected normal traffic and confirms stability over time.
 */
public class LoadSimulation extends Simulation {

  private static final String BASE_URL =
      System.getProperty("baseUrl",
          System.getenv().getOrDefault("BASE_URL",
              "http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek"));

  HttpProtocolBuilder httpProtocol =
      http.baseUrl(BASE_URL)
          .acceptHeader("text/html,application/xhtml+xml")
          .userAgentHeader("Gatling-Load");

  ScenarioBuilder scn =
      scenario("Compliment-Roast journey")
          .exec(http("Get home").get("/").check(status().is(200)))
          .pause(1)
          .exec(http("Compliment").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "compliment")
              .check(status().is(200)))
          .pause(1)
          .exec(http("Roast").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "roast")
              .check(status().is(200)));

  {
    setUp(
        scn.injectOpen(
            constantUsersPerSec(20).during(Duration.ofMinutes(5))))
        .protocols(httpProtocol);
  }
}
```

- [ ] **Step 3: Create `StressSimulation.java`**

```java
package simulations;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;

import io.gatling.javaapi.core.*;
import io.gatling.javaapi.http.*;
import java.time.Duration;

/**
 * Stress test: aggressively ramp from 10 to 150 arrivals/second over 5 minutes
 * to push the app past comfortable capacity and observe how it degrades/recovers.
 */
public class StressSimulation extends Simulation {

  private static final String BASE_URL =
      System.getProperty("baseUrl",
          System.getenv().getOrDefault("BASE_URL",
              "http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek"));

  HttpProtocolBuilder httpProtocol =
      http.baseUrl(BASE_URL)
          .acceptHeader("text/html,application/xhtml+xml")
          .userAgentHeader("Gatling-Stress");

  ScenarioBuilder scn =
      scenario("Compliment-Roast journey")
          .exec(http("Get home").get("/").check(status().is(200)))
          .pause(1)
          .exec(http("Compliment").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "compliment")
              .check(status().is(200)))
          .pause(1)
          .exec(http("Roast").post("/")
              .formParam("name", "LoadTester")
              .formParam("action", "roast")
              .check(status().is(200)));

  {
    setUp(
        scn.injectOpen(
            rampUsersPerSec(10).to(150).during(Duration.ofMinutes(5))))
        .protocols(httpProtocol);
  }
}
```

- [ ] **Step 4: Verify all three compile (does NOT run the long tests)**

Run (PowerShell):
```powershell
cd gatling; .\mvnw.cmd -q test-compile; cd ..
```
Expected: `BUILD SUCCESS`, no compile errors. (Downloads Gatling deps on first run.)

- [ ] **Step 5: Commit**

```bash
git add gatling/src
git commit -m "Add Gatling max-limit, load, and stress simulations"
```

---

### Task 7: Add the Jenkins pipelines

**Files:**
- Create: `jenkins/Jenkinsfile.deploy`
- Create: `jenkins/Jenkinsfile.tests`
- Create: `jenkins/Jenkinsfile.monitor`
- Create: `jenkins/Jenkinsfile.gatling`

- [ ] **Step 1: Create `jenkins/Jenkinsfile.deploy`** (main pipeline: Git → Tomcat)

```groovy
pipeline {
  agent any
  environment {
    TOMCAT_WEBAPPS = 'C:\\apache-tomcat-10.1.34\\webapps'
    APP_FOLDER     = 'compliment-tal-fellner-reich-kadmon-kokotek'
    APP_URL        = 'http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/'
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Deploy to Tomcat') {
      steps {
        bat '''
          if not exist "%TOMCAT_WEBAPPS%\\%APP_FOLDER%" mkdir "%TOMCAT_WEBAPPS%\\%APP_FOLDER%"
          copy /Y index.jsp "%TOMCAT_WEBAPPS%\\%APP_FOLDER%\\index.jsp"
        '''
      }
    }
    stage('Smoke test') {
      steps {
        bat 'powershell -NoProfile -Command "$r = Invoke-WebRequest -UseBasicParsing $env:APP_URL -TimeoutSec 20; if ($r.StatusCode -ne 200) { exit 1 } else { Write-Host (\'OK \' + $r.StatusCode) }"'
      }
    }
  }
}
```

- [ ] **Step 2: Create `jenkins/Jenkinsfile.tests`** (Playwright)

```groovy
pipeline {
  agent any
  environment {
    BASE_URL = 'http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/'
  }
  stages {
    stage('Install') {
      steps {
        dir('tests') {
          bat 'npm install'
          bat 'npx playwright install chromium'
        }
      }
    }
    stage('Test') {
      steps {
        dir('tests') {
          bat 'npx playwright test'
        }
      }
    }
  }
  post {
    always {
      junit testResults: 'tests/results.xml', allowEmptyResults: true
      publishHTML(target: [reportDir: 'tests/playwright-report', reportFiles: 'index.html',
        reportName: 'Playwright Report', keepAll: true, alwaysLinkToLastBuild: true, allowMissing: true])
    }
  }
}
```

- [ ] **Step 3: Create `jenkins/Jenkinsfile.monitor`** (5-minute heartbeat)

```groovy
pipeline {
  agent any
  triggers { cron('H/5 * * * *') }
  environment {
    APP_URL = 'http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek/'
  }
  stages {
    stage('Ping') {
      steps {
        bat 'powershell -NoProfile -Command "try { $r = Invoke-WebRequest -UseBasicParsing $env:APP_URL -TimeoutSec 20; Write-Host (\'UP \' + $r.StatusCode) } catch { Write-Host \'DOWN\'; exit 1 }"'
      }
    }
  }
}
```

- [ ] **Step 4: Create `jenkins/Jenkinsfile.gatling`** (parameterized max/load/stress)

```groovy
pipeline {
  agent any
  parameters {
    choice(name: 'TEST_TYPE', choices: ['MAX', 'LOAD', 'STRESS'],
           description: 'Which Gatling simulation to run')
  }
  environment {
    BASE_URL = 'http://localhost:8080/compliment-tal-fellner-reich-kadmon-kokotek'
  }
  stages {
    stage('Run Gatling') {
      steps {
        dir('gatling') {
          script {
            def sim = [
              MAX:    'simulations.MaxLimitSimulation',
              LOAD:   'simulations.LoadSimulation',
              STRESS: 'simulations.StressSimulation'
            ][params.TEST_TYPE]
            bat "mvnw.cmd gatling:test -Dgatling.simulationClass=${sim} -DbaseUrl=%BASE_URL%"
          }
        }
      }
    }
  }
  post {
    always {
      archiveArtifacts artifacts: 'gatling/target/gatling/**', allowEmptyArchive: true
    }
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add jenkins/
git commit -m "Add Jenkins pipelines: deploy, tests, monitor, gatling"
```

---

### Task 8: Write the README runbook

**Files:**
- Create: `docs/README.md`

- [ ] **Step 1: Create `docs/README.md`** with these sections (full prose, no placeholders):
  - **Overview** — what the app is and the pipeline goal.
  - **Prerequisites** — Tomcat 10.1.34, Java 21, Node 20, Jenkins; versions detected.
  - **Local deploy** — the exact PowerShell from Task 1 (start Tomcat, copy to the named folder, verify URL).
  - **Playwright tests** — `cd tests; npm install; npx playwright install chromium; npx playwright test`; how `BASE_URL` switches between localhost and the Render URL; where `results.xml` and the HTML report land; the 5 validations + rationale (positive vs negative, assert vs verify) for deliverable g.
  - **Gatling** — `cd gatling; .\mvnw.cmd gatling:test -Dgatling.simulationClass=simulations.MaxLimitSimulation`; same for Load/Stress; where the `index.html` report is (`gatling/target/gatling/<run>/index.html`) and how to export to PDF; how to read the max limit from the report (deliverable j).
  - **Jenkins setup** — plugins to install (Git, Pipeline, JUnit, HTML Publisher); create 4 Pipeline jobs each "Pipeline script from SCM" pointing at the repo with Script Path = `jenkins/Jenkinsfile.deploy` / `.tests` / `.monitor` / `.gatling`; note the monitor job's 5-min cron and that the Jenkins service account needs write access to the Tomcat webapps folder.
  - **Free hosting (Render bonus)** — create a Render account → New → Web Service → connect the GitHub repo → Render auto-detects the `Dockerfile` → set env var `PORT=8080` → deploy → copy the public `*.onrender.com` URL.
  - **Monitoring (UptimeRobot)** — create an HTTP(s) monitor on the public/local URL at a 5-minute interval; screenshot the "Up" status for deliverable e.
  - **HAR capture (deliverables h, i)** — open the app in Chrome DevTools → Network tab → record → type a name → click Compliment → click Roast → export HAR; the documented scenario text.

- [ ] **Step 2: Commit**

```bash
git add docs/README.md
git commit -m "Add project README runbook"
```

---

### Task 9: Write the deliverables checklist

**Files:**
- Create: `docs/DELIVERABLES.md`

- [ ] **Step 1: Create `docs/DELIVERABLES.md`** — a table mapping all 12 email items (a–l) to where each artifact lives or what manual step produces it, plus the email subject line `Final Exercise from: Moshe Tal, Shoham Fellner, Amit Reich, Omri Kadmon, Dor Kokotek` and recipient `mosh.mta2@gmail.com`. Include the "what app max limit is and why" guidance pointing to the Gatling max-limit report.

- [ ] **Step 2: Commit**

```bash
git add docs/DELIVERABLES.md
git commit -m "Add deliverables checklist for the 12 email items"
```

---

### Task 10: Push the branch to GitHub

**Files:** none (git remote operation)

- [ ] **Step 1: Confirm the remote and branch**

Run (PowerShell):
```powershell
git remote -v
git branch --show-current
```
Expected: an `origin` pointing at `https://github.com/moshetal/DevOpsCourseFinalProject` (add it with `git remote add origin <url>` if missing) and branch `devops-final-project`.

- [ ] **Step 2: Push**

Run:
```bash
git push -u origin devops-final-project
```
Expected: branch published; the run prints a PR-compare URL.

---

## Self-review notes
- Spec coverage: app (#1) Task 1; Git/GitHub (#2) Task 10; named Tomcat folder (#3) + deploy via Jenkins (#4) Tasks 1 & 7; bonus live host (#5) Tasks 4 & 8; monitor every 5 min (#6) Tasks 7 & 8; Playwright 5 validations (#7) Tasks 2–3; Gatling max/load/stress (#8–10) Tasks 5–7; all 12 deliverables Task 9.
- Constants (folder name, URLs, simulation FQCNs `simulations.*`) are consistent across Playwright config, Gatling sims, and all four Jenkinsfiles.
- Long-running Gatling tests are verified by `test-compile` only (not executed) to keep the build fast; actual runs happen via the Jenkins Gatling job / manual `mvnw gatling:test`.
