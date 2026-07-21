import { test, expect } from '@playwright/test';
import { ReinventionServicesPage } from '../../pages/ReinventionServicesPage';

// AC-2: each nav item scrolls to its section, which shows the expected header.
const AC2_SECTIONS = [
  { item: 'Reinvention Partners', header: 'Reinvention Partners' },
  { item: 'Reinvention Engines', header: 'Reinvention Engines' },
  { item: 'Client Success', header: 'Client Success' },
  { item: 'Industries', header: 'We bring deep industry expertise' },
  { item: 'Client Stories', header: 'We make reinvention real' },
] as const;

// US200 - Reinvention Services: top navigation bar
// AC-1: the sub-nav shows five items, in order (Reinvention Partners, Reinvention
//       Engines, Client Success, Industries, Client Stories)
// AC-2: clicking a nav item scrolls the page to the corresponding section
//       (section snaps to just below the sticky sub-nav; URL hash does not change)
// AC-3: hovering a nav item underlines the text (animated ::after bar, 0 → full width);
//       it is not underlined at rest.

test.describe('US200 - Reinvention Services top navigation bar', () => {
  let rsp: ReinventionServicesPage;

  test.beforeEach(async ({ page }) => {
    rsp = new ReinventionServicesPage(page);
    await rsp.navigate();
  });

  // TC-001 (ADO 20001) - AC-1 positive
  test('20001 - AC1 - all five nav items are present and visible', async () => {
    for (const name of ReinventionServicesPage.NAV_ITEMS) {
      await expect(rsp.itemLabel(name)).toBeVisible();
    }
    await expect(rsp.itemLabels()).toHaveCount(ReinventionServicesPage.NAV_ITEMS.length);
  });

  // TC-002 (ADO 20002) - AC-1 edge (order)
  test('20002 - AC1 - nav items appear in the expected left-to-right order', async () => {
    await expect(rsp.itemLabels()).toHaveText([...ReinventionServicesPage.NAV_ITEMS]);
  });

  // TC-003 (ADO 20003) - AC-2 positive (clicking each nav item scrolls to its
  // section and that section's expected header is shown in the viewport)
  test('20003 - AC2 - clicking each nav item scrolls to its section header', async () => {
    for (const { item, header } of AC2_SECTIONS) {
      await rsp.clickItem(item);
      // The correct section is scrolled into view (its container is tall and
      // snaps to just under the sticky sub-nav) and shows the expected header.
      await expect(rsp.section(item)).toBeInViewport();
      await expect(rsp.sectionHeading(item)).toBeVisible();
      await expect(rsp.sectionHeading(item)).toHaveText(header);
    }
  });

  // TC-004 (ADO 20004) - AC-3 positive (hover underlines)
  test('20004 - AC3 - hovering a nav item underlines the text', async () => {
    const name = 'Industries';
    expect(await rsp.underlineWidthPx(name)).toBe(0); // not underlined at rest
    await rsp.navLink(name).hover();
    await expect
      .poll(() => rsp.underlineWidthPx(name), { timeout: 5000 })
      .toBeGreaterThan(0); // underline bar animates in on hover
  });

  // TC-005 (ADO 20005) - AC-3 negative (not underlined by default)
  test('20005 - AC3 - nav item is not underlined by default', async () => {
    expect(await rsp.underlineWidthPx('Client Success')).toBe(0);
  });
});
