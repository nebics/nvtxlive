const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const outputDir = args[0] || 'screenshots';
const baseUrl = args[1] || 'http://localhost:4321';

const pagesConfig = JSON.parse(fs.readFileSync('pages.json', 'utf8'));
const pages = pagesConfig.pages;

async function captureScreenshots() {
  console.log('\n========================================');
  console.log('Full-Page Screenshot Capture (Playwright)');
  console.log('========================================\n');

  // Create output directory
  fs.mkdirSync(outputDir, { recursive: true });
  console.log(`Output directory: ${outputDir}/\n`);

  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 }
  });

  let count = 0;
  const total = pages.length;

  for (const pagePath of pages) {
    count++;
    const url = `${baseUrl}${pagePath.startsWith('/') ? pagePath : '/' + pagePath}`;

    // Generate filename
    let filename;
    if (pagePath === '/') {
      filename = 'index.png';
    } else {
      filename = pagePath.replace(/^\//, '').replace(/\//g, '_') + '.png';
    }

    const outputPath = path.join(outputDir, filename);

    console.log(`[${count}/${total}] Capturing: ${pagePath}`);

    try {
      const page = await context.newPage();
      await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
      await page.waitForTimeout(1000); // Wait for any animations
      await page.screenshot({ path: outputPath, fullPage: true });
      await page.close();
      console.log(`   ✓ Saved: ${outputPath}`);
    } catch (error) {
      console.log(`   ✗ Failed: ${error.message}`);
    }
  }

  await browser.close();

  console.log('\n========================================');
  console.log('✓ Screenshots complete!');
  console.log('========================================\n');

  const files = fs.readdirSync(outputDir).filter(f => f.endsWith('.png'));
  console.log(`Captured ${files.length} pages to: ${outputDir}/\n`);
  files.forEach(f => console.log(`  ${f}`));
}

captureScreenshots().catch(console.error);
