import { test, expect } from '@playwright/test';
import { ExamplePage } from '../../pages/ExamplePage';

// US123 - Example Story
// AC1: Given the user is on the home page, the page heading is visible
// AC2: Given the user is on the home page, a login button is present and enabled

test.describe('US123 - Example Story', () => {
  let examplePage: ExamplePage;

  test.beforeEach(async ({ page }) => {
    examplePage = new ExamplePage(page);
    await examplePage.navigate();
  });

  test('10001 - AC1 - should display the page heading', async () => {
    await expect(examplePage.heading).toBeVisible();
  });

  test('10002 - AC2 - should show an enabled login button on the home page', async () => {
    await expect(examplePage.loginButton).toBeVisible();
    await expect(examplePage.loginButton).toBeEnabled();
  });
});
