# Testing & Linting Guide

Comprehensive testing and linting setup for Scrutiny.

---

## Quick Start

```bash
# Run all checks (lint + format + test)
npm run check

# Run tests only
npm test

# Run tests with UI
npm run test:ui

# Run E2E tests
npm run test:e2e
```

---

## Frontend Testing

### Unit Tests (Vitest)

**Run tests:**
```bash
npm test                # Run once
npm run test:ui         # Interactive UI
npm run test:coverage   # With coverage report
```

**Example test:**
```typescript
// src/App.test.tsx
import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import App from "./App";

describe("App", () => {
  it("renders plan review UI", () => {
    render(<App />);
    expect(screen.getByText(/Claude Plan Review/i)).toBeInTheDocument();
  });
});
```

**Coverage report:**  
After running `npm run test:coverage`, open `coverage/index.html`

---

### E2E Tests (Playwright)

**Run tests:**
```bash
npm run test:e2e        # Headless
npm run test:e2e:ui     # Interactive UI
```

**Example test:**
```typescript
// e2e/plan-review.spec.ts
import { test, expect } from "@playwright/test";

test("should render plan review interface", async ({ page }) => {
  await page.goto("/");
  await expect(page.locator("h1")).toContainText("Claude Plan Review");
});
```

---

## Backend Testing

### Rust Tests (Cargo)

**Run tests:**
```bash
cd src-tauri
cargo test              # All tests
cargo test -- --nocapture  # With println! output
```

**Example test:**
```rust
#[test]
fn test_compute_diff_with_changes() {
    let original = "Step 1\nStep 2".to_string();
    let edited = "Step 1\nStep 1.5\nStep 2".to_string();
    
    let result = compute_diff(original, edited).unwrap();
    
    assert!(result.has_changes);
    assert!(result.lines.len() > 0);
}
```

---

## Linting

### Frontend Linting

**ESLint:**
```bash
npm run lint            # Check for issues
npm run lint:fix        # Auto-fix issues
```

**Config:** `.eslintrc.json`

**Prettier:**
```bash
npm run format          # Format all code
npm run format:check    # Check formatting
```

**Config:** `.prettierrc`

---

### Backend Linting

**Clippy:**
```bash
cd src-tauri
cargo clippy -- -D warnings
```

**Config:** `src-tauri/clippy.toml`

**rustfmt:**
```bash
cd src-tauri
cargo fmt              # Format code
cargo fmt -- --check   # Check formatting
```

**Config:** `src-tauri/rustfmt.toml`

---

## CI/CD

Tests run automatically on GitHub Actions for every PR:

- ✅ ESLint check
- ✅ Prettier format check
- ✅ Vitest unit tests
- ✅ Playwright E2E tests
- ✅ Cargo test
- ✅ Clippy check
- ✅ rustfmt check

**View results:** GitHub PR checks tab

---

## Pre-commit Checklist

Before committing, run:

```bash
npm run check
```

This runs:
1. Format check (Prettier + rustfmt)
2. Lint (ESLint + Clippy)
3. Tests (Vitest + cargo test)

**All green?** ✅ Ready to commit!

---

## Writing Tests

### Frontend Component Tests

**Best practices:**
- Test user behavior, not implementation
- Use `screen.getByRole` over `getByTestId`
- Mock Tauri API calls with `vi.mock`

**Example:**
```typescript
it("saves comment when user clicks save", async () => {
  const user = userEvent.setup();
  render(<App />);
  
  await user.click(screen.getByRole("button", { name: /Add Comment/i }));
  await user.type(screen.getByRole("textbox"), "Test comment");
  await user.click(screen.getByRole("button", { name: /Save/i }));
  
  expect(screen.getByText("Test comment")).toBeInTheDocument();
});
```

---

### Backend Rust Tests

**Best practices:**
- Test public API, not private functions
- Use `Result<(), String>` for test helpers
- Test error cases, not just happy path

**Example:**
```rust
#[test]
fn test_diff_handles_empty_strings() {
    let result = compute_diff("".to_string(), "".to_string()).unwrap();
    assert!(!result.has_changes);
    assert_eq!(result.lines.len(), 0);
}

#[test]
fn test_load_plan_returns_error_for_invalid_path() {
    let result = load_plan("/invalid/path".to_string());
    assert!(result.is_err());
}
```

---

## Debugging Tests

### Frontend

**Debug a single test:**
```bash
npm test -- App.test.tsx
```

**Debug with breakpoints:**
```typescript
import { debug } from "@testing-library/react";

it("test", () => {
  render(<App />);
  debug(); // Prints DOM to console
});
```

### Backend

**Run specific test:**
```bash
cargo test test_compute_diff_with_changes
```

**Print debug output:**
```rust
#[test]
fn test() {
    let result = compute_diff(original, edited).unwrap();
    println!("Result: {:?}", result); // Requires --nocapture
}
```

---

## Troubleshooting

### Vitest fails with "Cannot find module"

**Fix:** Install missing dependency
```bash
npm install -D jsdom
```

### Playwright fails to find browser

**Fix:** Install browsers
```bash
npx playwright install chromium
```

### Cargo test fails to compile

**Fix:** Clean and rebuild
```bash
cd src-tauri
cargo clean
cargo test
```

### ESLint complains about React version

**Fix:** It auto-detects from package.json (no action needed)

---

## Coverage Goals

| Area | Goal | Current |
|------|------|---------|
| Frontend Components | 80% | TBD |
| Rust Logic | 90% | TBD |
| E2E Critical Paths | 100% | TBD |

Run `npm run test:coverage` to check current coverage.

---

## Additional Resources

- [Vitest Docs](https://vitest.dev/)
- [Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Playwright Docs](https://playwright.dev/)
- [Rust Testing](https://doc.rust-lang.org/book/ch11-00-testing.html)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/master/)
