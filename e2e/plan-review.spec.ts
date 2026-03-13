import { test, expect } from "@playwright/test";

test.describe("Plan Review", () => {
  test("should render plan review interface", async ({ page }) => {
    await page.goto("/");
    await expect(page.locator("h1")).toContainText("Scrutiny");
  });

  test("should open comment dialog", async ({ page }) => {
    await page.goto("/");
    await page.click('button:has-text("Add Comment")');
    await expect(page.locator("textarea")).toBeVisible();
  });

  test("should show approve and cancel buttons", async ({ page }) => {
    await page.goto("/");
    await expect(page.locator('button:has-text("Approve")')).toBeVisible();
    await expect(page.locator('button:has-text("Cancel")')).toBeVisible();
  });
});
