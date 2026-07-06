import { test, expect } from '@playwright/test';

test('Homepage loads correctly and games are accessible', async ({ page }) => {
  // 1. Visit homepage
  await page.goto('/');
  await expect(page).toHaveTitle(/لعبتنا/);

  // 2. Check title
  const heading = page.locator('h1', { hasText: 'لعبتنا' });
  await expect(heading).toBeVisible();

  // 3. Try to navigate to Domino
  const dominoButton = page.locator('h3', { hasText: 'دومينو' }).first();
  await expect(dominoButton).toBeVisible();
  
  // Wait for React hydration
  await page.waitForTimeout(1000);
  
  // Click the Domino button
  await dominoButton.click();

  // 4. Verify we are in the Play page with the create room button for Domino
  await expect(page).toHaveURL(/.*\/play\?game=domino/);
  const createRoomBtn = page.locator('button', { hasText: 'إنشاء غرفة' });
  await expect(createRoomBtn).toBeVisible();
});
