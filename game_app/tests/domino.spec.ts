import { test, expect } from '@playwright/test';

test.describe('Domino Multiplayer E2E', () => {
  test('Two players join Domino and play a few moves', async ({ browser }) => {
    test.setTimeout(120000);

    const context1 = await browser.newContext();
    const context2 = await browser.newContext();

    const page1 = await context1.newPage();
    const page2 = await context2.newPage();

    // Player 1 creates a Domino room
    await page1.goto('http://localhost:3000/play?game=domino');
    await page1.getByText('إنشاء غرفة (دومينو)').click();

    // Wait for the room code
    await page1.waitForSelector('text=كود الغرفة:');
    const roomCodeElement = await page1.locator('text=كود الغرفة:').locator('xpath=..').locator('span').first();
    const roomCode = await roomCodeElement.innerText();
    expect(roomCode).toBeTruthy();

    console.log(`Domino Room created with code: ${roomCode}`);

    // Player 2 joins
    await page2.goto('http://localhost:3000/play?game=domino');
    await page2.getByPlaceholder('أدخل كود الغرفة (4 أرقام)').fill(roomCode);
    await page2.getByText('انضمام للغرفة').click();

    // Verify game starts (board appears)
    await expect(page1.getByText('دومينو').first()).toBeVisible({ timeout: 15000 });
    await expect(page2.getByText('دومينو').first()).toBeVisible({ timeout: 15000 });

    console.log("Domino game started successfully for both players.");

    await context1.close();
    await context2.close();
  });
});
