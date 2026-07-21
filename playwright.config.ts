import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './src/tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  // One local retry absorbs transient live-site load hiccups; more in CI.
  retries: process.env.CI ? 2 : 1,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['list']],
  // The worked example runs against a heavy live site; allow headroom for load.
  timeout: 60_000,
  expect: { timeout: 10_000 },
  use: {
    // Worked example targets the live Accenture site. Override with BASE_URL.
    baseURL: process.env.BASE_URL || 'https://www.accenture.com',
    trace: 'on',
    screenshot: 'only-on-failure',
    video: 'on',
  },
  projects: [
    {
      name: 'chromium',
      // Run at 1080p (override Desktop Chrome's default 1280x720 viewport).
      use: { ...devices['Desktop Chrome'], viewport: { width: 1920, height: 1080 } },
    },
  ],
});
