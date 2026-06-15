// Records a HAR of the documented scenario (deliverable h/i) against the live site:
// load -> type a name -> Compliment -> type a name -> Roast.
// Usage: BASE_URL=... node record-har.mjs   (defaults to the live Render URL)
import { chromium } from '@playwright/test';

const BASE = process.env.BASE_URL || 'https://devopscoursefinalproject.onrender.com/index.jsp';
const OUT = process.env.HAR_OUT || '../docs/compliment-roast.har';

const browser = await chromium.launch();
const context = await browser.newContext({
  recordHar: { path: OUT, content: 'embed' },
});
const page = await context.newPage();

await page.goto(BASE, { waitUntil: 'networkidle' });
await page.fill('#nameInput', 'MTA Group');
await page.getByRole('button', { name: /Compliment/ }).click();
await page.waitForLoadState('networkidle');
await page.fill('#nameInput', 'DevOps Team');
await page.getByRole('button', { name: /Roast/ }).click();
await page.waitForLoadState('networkidle');

await context.close(); // flushes the HAR to disk
await browser.close();
console.log('HAR written to', OUT);
