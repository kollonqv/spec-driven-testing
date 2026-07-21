import { Page, Locator } from '@playwright/test';

export class ExamplePage {
  readonly heading: Locator;
  readonly loginButton: Locator;

  constructor(readonly page: Page) {
    this.heading     = page.getByRole('heading', { level: 1 });
    this.loginButton = page.getByRole('button', { name: /login|sign in/i });
  }

  async navigate() {
    await this.page.goto('/');
  }

  async login(username: string, password: string) {
    await this.page.getByLabel('Username').fill(username);
    await this.page.getByLabel('Password').fill(password);
    await this.loginButton.click();
  }
}
