import { test, expect } from '@playwright/test';

test.describe('Connect 4 Multiplayer E2E', () => {
  test('Full Connect 4 Match', async ({ browser }) => {
    test.setTimeout(120000); // 2 minutes max

    const context1 = await browser.newContext();
    const context2 = await browser.newContext();

    const page1 = await context1.newPage();
    const page2 = await context2.newPage();

    // Player 1 goes to Connect 4 lobby
    await page1.goto('http://localhost:3000/play?game=connect4');
    
    // Player 1 creates a room
    await page1.getByText('إنشاء غرفة (Connect 4)').click();

    // Wait for the room code to appear
    await page1.waitForSelector('text=كود الغرفة:');
    const roomCodeElement = await page1.locator('text=كود الغرفة:').locator('xpath=..').locator('span').first();
    const roomCode = await roomCodeElement.innerText();
    expect(roomCode).toBeTruthy();
    expect(roomCode.length).toBe(4);

    console.log(`Room created with code: ${roomCode}`);

    // Player 2 goes to Connect 4 lobby
    await page2.goto('http://localhost:3000/play?game=connect4');

    // Player 2 enters code and joins
    await page2.getByPlaceholder('أدخل كود الغرفة (4 أرقام)').fill(roomCode);
    await page2.getByText('انضمام للغرفة').click();

    // Wait for both players to enter the playing state (waiting for opponent should disappear)
    await expect(page1.getByText('دورك الآن').or(page1.getByText('دور الخصم'))).toBeVisible({ timeout: 15000 });
    await expect(page2.getByText('دورك الآن').or(page2.getByText('دور الخصم'))).toBeVisible({ timeout: 15000 });

    // Helper function to play a move
    const playMove = async (col: number) => {
      // Find whose turn it is
      const p1Turn = await page1.getByText('دورك الآن').isVisible();
      if (p1Turn) {
        await page1.getByTestId(`col-${col}`).click();
        await expect(page1.getByText('دور الخصم')).toBeVisible();
      } else {
        await page2.getByTestId(`col-${col}`).click();
        await expect(page2.getByText('دور الخصم')).toBeVisible();
      }
    };

    // Let's win vertically in column 0
    // Player 1: Col 0, Player 2: Col 1
    await playMove(0);
    await playMove(1);
    await playMove(0);
    await playMove(1);
    await playMove(0);
    await playMove(1);
    
    // Winning move for Player 1
    await playMove(0);

    // Verify game over state
    await expect(page1.getByText('لقد فزت! 🎉')).toBeVisible({ timeout: 10000 });
    await expect(page2.getByText('لقد خسرت 😔')).toBeVisible({ timeout: 10000 });

    // Verify rematch button is visible for both
    await expect(page1.getByText('إعادة المباراة (Rematch)')).toBeVisible();
    await expect(page2.getByText('إعادة المباراة (Rematch)')).toBeVisible();

    console.log("Connect 4 game finished successfully!");

    await context1.close();
    await context2.close();
  });
});
