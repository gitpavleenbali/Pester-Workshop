import fs from "fs";
import path from "path";

export function getModuleContent(slug: string): string {
  const filePath = path.join(process.cwd(), "content", `${slug}.md`);
  return fs.readFileSync(filePath, "utf-8");
}

export const MODULE_SLUGS = [
  "01-pester-introduction",
  "02-enterprise-positioning",
  "03-mocking-and-test-isolation",
] as const;

export const MODULE_META: Record<string, { title: string; duration: string; description: string }> = {
  "01-pester-introduction": {
    title: "Fundamentals of Unit Testing — Introduction & Context",
    duration: "~60 minutes",
    description: "Software testing types, FIRST principles, AAA pattern, Pester 5 structure, assertions, VS Code integration.",
  },
  "02-enterprise-positioning": {
    title: "Enterprise Positioning — Pester Architecture for Large Organizations",
    duration: "~30 minutes",
    description: "CI/CD integration, governance, quality gates, maturity model, GitHub Actions, test metrics.",
  },
  "03-mocking-and-test-isolation": {
    title: "Mocking & Test Isolation",
    duration: "~30 minutes",
    description: "Mock, Should -Invoke, ParameterFilter, TestDrive, TestRegistry, .NET testing, best practices.",
  },
};
