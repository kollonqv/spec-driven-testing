import { Page, Locator } from '@playwright/test';

/**
 * Page Object for the Accenture Reinvention Services page.
 * Target: https://www.accenture.com/ca-en/about/reinvention-services
 *
 * Selectors, scroll and hover mechanics below were captured by live investigation
 * and are documented in src/tests/reinventionServices/US200_reinventionServicesNav.spec.md.
 * Key findings:
 *  - The in-page sub-nav ("rad-subnav-bar") holds five anchor links.
 *  - Clicking an item scrolls its section to just below the sticky sub-nav
 *    (section top ≈ 52px); the URL hash does NOT change (JS smooth scroll).
 *  - The hover "underline" is an animated ::after bar on the label span whose
 *    width grows from 0 to the text width.
 */
export class ReinventionServicesPage {
  /** The five expected sub-nav items, in order (traces to AC-1). */
  static readonly NAV_ITEMS = [
    'Reinvention Partners',
    'Reinvention Engines',
    'Client Success',
    'Industries',
    'Client Stories',
  ] as const;

  /** Nav item → the id of the section it scrolls to (from live investigation). */
  static readonly SECTION_IDS: Record<string, string> = {
    'Reinvention Partners': 'block-reinvention-partners',
    'Reinvention Engines': 'block-reinvention-engines',
    'Client Success': 'block-client-success',
    'Industries': 'block-we-bring-deep-industry-expertise',
    'Client Stories': 'block-carousel-we-make-reinvention-real',
  };

  /** Nav item → the exact heading text shown in its section (from live investigation). */
  static readonly SECTION_HEADERS: Record<string, string> = {
    'Reinvention Partners': 'Reinvention Partners',
    'Reinvention Engines': 'Reinvention Engines',
    'Client Success': 'Client Success',
    'Industries': 'We bring deep industry expertise',
    'Client Stories': 'We make reinvention real',
  };

  readonly nav: Locator;

  constructor(readonly page: Page) {
    // The in-page section nav, identified as the navigation landmark that
    // contains the first sub-nav item (confirmed unique during investigation).
    this.nav = page.getByRole('navigation').filter({
      has: page.getByRole('link', { name: 'Reinvention Partners' }),
    });
  }

  async navigate() {
    await this.page.goto('/ca-en/about/reinvention-services', {
      waitUntil: 'domcontentloaded',
    });
    await this.dismissConsentIfPresent();
    // Heavy live page: wait for the first sub-nav item to render before interacting.
    await this.page
      .getByRole('link', { name: 'Reinvention Partners', exact: true })
      .first()
      .waitFor({ state: 'visible', timeout: 45_000 });
  }

  /** Dismiss the OneTrust cookie/consent banner if it appears. */
  async dismissConsentIfPresent() {
    const accept = this.page.getByRole('button', { name: /accept all cookies/i });
    if (await accept.isVisible().catch(() => false)) {
      await accept.click();
    }
  }

  /** A single sub-nav item as an accessible link (used to hover/click). */
  navLink(name: string): Locator {
    return this.nav.getByRole('link', { name, exact: true });
  }

  /** Click a sub-nav item (scrolls the page to its section). */
  async clickItem(name: string) {
    await this.navLink(name).click();
  }

  /** The page section a nav item scrolls to. */
  section(name: string): Locator {
    return this.page.locator('#' + ReinventionServicesPage.SECTION_IDS[name]);
  }

  /** The expected heading inside a nav item's section. */
  sectionHeading(name: string): Locator {
    return this.section(name).getByRole('heading', {
      name: ReinventionServicesPage.SECTION_HEADERS[name],
      exact: true,
    });
  }

  /** The visible label span for an item — the element carrying the ::after underline. */
  itemLabel(name: string): Locator {
    // CSS class is the real mechanism for the animated underline; encapsulated here.
    return this.nav.locator('span.rad-subnav-bar__link-text', { hasText: name });
  }

  /** All visible sub-nav label spans, in DOM order (for order assertions). */
  itemLabels(): Locator {
    return this.nav.locator('span.rad-subnav-bar__link-text');
  }

  /** Width in px of the item's ::after underline bar (0 at rest, > 0 on hover). */
  async underlineWidthPx(name: string): Promise<number> {
    return this.itemLabel(name).evaluate(
      (el) => parseFloat(getComputedStyle(el, '::after').width) || 0,
    );
  }
}
