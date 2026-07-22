# Business Rules — Reinvention Services navigation

> Functional rules that govern *expected* behaviour. These justify acceptance criteria and suggest where negatives/edges are worthwhile. No implementation detail.

## Sub-navigation
- **BR-1.** The sub-nav lists the page's major sections, **in document order** (top-to-bottom of the page). → *Justifies an order edge case.*
- **BR-2.** The sub-nav is **persistent/sticky** while the user scrolls the page, so navigation is always reachable.
- **BR-3.** Selecting a sub-nav item performs **in-page navigation** to that item's section (the user is taken to the corresponding content), and that section's heading is shown.
- **BR-4.** Sub-nav items give a **visual affordance on hover** (an interactive cue) so users can tell they're actionable.

## Content
- **BR-5.** Every section is introduced by a **heading** that identifies it (see the item→heading map in `application-overview.md`).
- **BR-6.** The set and order of sections is content-managed and can change over time — tests should assert the *expected* set/order from the story's ACs, and drift is a signal to revisit the story, not to loosen the test.

## How these inform test design
- BR-1 → an **edge** test on ordering (not just presence).
- BR-3 → verify the *correct* section/heading is reached per item (not merely "something scrolled").
- BR-4 → verify the affordance appears **on hover** and is **absent at rest** (a negative that proves causation).
- BR-6 → keep expecteds tied to the AC; don't auto-adapt to whatever the live page currently shows.
