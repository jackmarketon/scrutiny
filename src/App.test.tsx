import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";
import App from "./App";

// Mock Tauri API
vi.mock("@tauri-apps/api/core", () => ({
  invoke: vi.fn(),
}));

describe("App", () => {
  it("renders plan review UI", () => {
    render(<App />);
    expect(screen.getByText(/Claude Plan Review/i)).toBeInTheDocument();
  });

  it("shows add comment button", () => {
    render(<App />);
    const button = screen.getByRole("button", { name: /Add Comment/i });
    expect(button).toBeInTheDocument();
  });

  it("opens comment dialog when add comment clicked", () => {
    render(<App />);
    const button = screen.getByRole("button", { name: /Add Comment/i });
    fireEvent.click(button);
    expect(screen.getByRole("textbox")).toBeInTheDocument();
  });

  it("shows approve and cancel buttons", () => {
    render(<App />);
    expect(screen.getByRole("button", { name: /Approve/i })).toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Cancel/i })).toBeInTheDocument();
  });
});
