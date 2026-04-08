import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Pester Workshop — PowerShell Testing & Mocking",
  description:
    "A comprehensive 2-day workshop for PowerShell testing with Pester 5 — the ubiquitous test and mock framework for PowerShell.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <body className="min-h-screen bg-[#0a0e17] text-slate-200 antialiased font-sans">
        {children}
      </body>
    </html>
  );
}
