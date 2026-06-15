// Converts the 3 Gatling HTML reports to PDF (deliverable l).
import { chromium } from '@playwright/test';
import { mkdirSync } from 'fs';

const base = 'C:/Users/dor.kokotek/Documents/GitHub/DevOpsCourseFinalProject';
const reports = [
  ['max-limit', `${base}/gatling/target/gatling/maxlimitsimulation-20260615164802502/index.html`],
  ['load',      `${base}/gatling/target/gatling/loadsimulation-20260615165043450/index.html`],
  ['stress',    `${base}/gatling/target/gatling/stresssimulation-20260615165620893/index.html`],
];
const outDir = `${base}/docs/gatling-reports`;
mkdirSync(outDir, { recursive: true });

const browser = await chromium.launch();
for (const [name, file] of reports) {
  const page = await browser.newPage();
  await page.goto('file:///' + file, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500); // let Highcharts render
  const out = `${outDir}/gatling-${name}.pdf`;
  await page.pdf({ path: out, format: 'A4', landscape: true, printBackground: true,
    margin: { top: '10mm', bottom: '10mm', left: '8mm', right: '8mm' } });
  console.log('wrote', out);
  await page.close();
}
await browser.close();
console.log('done');
