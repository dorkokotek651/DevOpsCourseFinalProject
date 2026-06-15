// Captures durable PNG screenshots of the visual deliverables into docs/screenshots/.
import { chromium } from '@playwright/test';
import { mkdirSync } from 'fs';

const base = 'C:/Users/dor.kokotek/Documents/GitHub/DevOpsCourseFinalProject';
const gat = `${base}/gatling/target/gatling`;
const outDir = `${base}/docs/screenshots`;
mkdirSync(outDir, { recursive: true });

const shots = [
  // c: app on local Tomcat
  ['app-tomcat-8081', 'http://localhost:8081/compliment-tal-fellner-reich-kadmon-kokotek/', 1500],
  // b: public GitHub repo
  ['github-repo', 'https://github.com/dorkokotek651/DevOpsCourseFinalProject', 2500],
  // k/l: Gatling reports
  ['gatling-max-limit', `file:///${gat}/maxlimitsimulation-20260615164802502/index.html`, 2500],
  ['gatling-load', `file:///${gat}/loadsimulation-20260615165043450/index.html`, 2500],
  ['gatling-stress', `file:///${gat}/stresssimulation-20260615165620893/index.html`, 2500],
];

const browser = await chromium.launch();
for (const [name, url, settle] of shots) {
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  try {
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    await page.waitForTimeout(settle);
    await page.screenshot({ path: `${outDir}/${name}.png`, fullPage: true });
    console.log('saved', name);
  } catch (e) {
    console.log('FAILED', name, String(e).substring(0, 80));
  }
  await page.close();
}
await browser.close();
console.log('done');
