"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import { Layers, Shield, Beaker, Database, Box, BarChart3 } from "lucide-react";

const categories = [
  {
    icon: Layers,
    title: "Test Structure",
    color: "text-violet-400",
    items: [
      { name: "Describe", desc: "Top-level test suite grouping — named after the function under test" },
      { name: "Context", desc: "Sub-groups tests by scenario (e.g., 'When VM exists' vs 'When VM is missing')" },
      { name: "It", desc: "Individual test case — one assertion per test ideally" },
      { name: "BeforeAll", desc: "Runs ONCE before all tests in its block — for imports and shared setup" },
      { name: "BeforeEach", desc: "Runs before EVERY It — gives each test a clean, independent state" },
      { name: "AfterAll / AfterEach", desc: "Cleanup — runs once after block or after every It" },
    ],
  },
  {
    icon: Shield,
    title: "Assertions (Should)",
    color: "text-green-400",
    items: [
      { name: "Should -Be", desc: "Equality check (case-insensitive)" },
      { name: "Should -BeExactly", desc: "Equality check (case-sensitive)" },
      { name: "Should -Throw", desc: "Asserts code throws — wrap call in { } scriptblock" },
      { name: "Should -Throw '*pattern*'", desc: "Exception message wildcard matching" },
      { name: "Should -Match", desc: "Regex pattern match on string values" },
      { name: "Should -BeNullOrEmpty", desc: "Asserts null, empty string, or empty collection" },
      { name: "Should -Not -Be", desc: "Negated assertion — inverts any Should operator" },
      { name: "Should -BeGreaterThan", desc: "Numeric comparison: actual > expected" },
      { name: "Should -HaveCount", desc: "Asserts collection has exactly N items" },
      { name: "Should -Exist", desc: "Asserts file or path exists on disk" },
      { name: "Should -Invoke", desc: "Verifies a mocked command was called (with -Times N)" },
      { name: "Should -InvokeVerifiable", desc: "Asserts all -Verifiable mocks were invoked" },
    ],
  },
  {
    icon: Beaker,
    title: "Mocking",
    color: "text-yellow-400",
    items: [
      { name: "Mock <Cmd> { }", desc: "Replace a real command with a fake — the core of isolation" },
      { name: "-ParameterFilter", desc: "Route different mock responses based on input parameters" },
      { name: "-Verifiable", desc: "Mark a mock as required — fails if never called" },
      { name: "-ModuleName", desc: "Inject mock into a module's internal scope" },
      { name: "Should -Invoke -Times 0", desc: "Prove a command was NOT called (negative assertion)" },
      { name: "Should -Invoke -Exactly", desc: "Exact count — not 'at least', but 'exactly'" },
      { name: "Context-scoped overrides", desc: "Different Contexts can override parent mocks with their own" },
      { name: "Mock native apps", desc: "Mock git, curl, etc. using $args to detect subcommands" },
      { name: "$PesterBoundParameters", desc: "Access original parameters inside mock (Pester 5.2+)" },
    ],
  },
  {
    icon: Database,
    title: "Data-Driven Testing",
    color: "text-blue-400",
    items: [
      { name: "-TestCases @()", desc: "Run the same It block with multiple @{} datasets" },
      { name: "<Param> substitution", desc: "Template variables in test name get replaced with actual values" },
      { name: "Boundary testing", desc: "Systematic off-by-one checks (e.g., Cost=100 vs Threshold=100)" },
      { name: "param() block", desc: "Receives -TestCases hashtable keys as variables inside It" },
    ],
  },
  {
    icon: Box,
    title: "Test Isolation",
    color: "text-cyan-400",
    items: [
      { name: "TestDrive:\\", desc: "Temporary file system — auto-cleaned after each Describe" },
      { name: "TestRegistry:\\", desc: "Temporary registry hive (Windows) — auto-cleaned" },
      { name: "$script: scope", desc: "Persist variables across scriptblock invocations (retry tests)" },
      { name: "Discovery vs Execution", desc: "Code outside BeforeAll/It runs during Discovery — don't put logic there" },
      { name: "Block-scoped mocks", desc: "Pester 5: mocks only live in the block where defined (changed from v4)" },
    ],
  },
  {
    icon: BarChart3,
    title: "Enterprise & CI/CD",
    color: "text-orange-400",
    items: [
      { name: "New-PesterConfiguration", desc: "The Pester 5 way — full control over run, coverage, output" },
      { name: "NUnit XML output", desc: "Test results for CI dashboards (Azure DevOps, GitHub Actions)" },
      { name: "JaCoCo coverage", desc: "Code coverage format consumable by Codecov, SonarQube" },
      { name: "-CI switch", desc: "Shortcut: exit code + XML output + coverage in one flag" },
      { name: "CIFormat = 'GithubActions'", desc: "Native annotations in GitHub PR checks" },
      { name: "80% coverage threshold", desc: "Enterprise standard — CoveragePercentTarget in config" },
      { name: "PSScriptAnalyzer", desc: "Static analysis — run before Pester in CI pipeline" },
    ],
  },
];

export default function ConceptsPage() {
  return (
    <>
      <Nav />
      <div className="max-w-5xl mx-auto px-4 py-16">
        <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">Reference</div>
        <h1 className="text-3xl font-extrabold mb-2">Pester Concepts Covered</h1>
        <p className="text-slate-400 mb-10 max-w-2xl">
          Every concept below is demonstrated in the lab tests with inline comments.
          Use the Explain button in the browser UI to see them in context.
        </p>

        <div className="space-y-8">
          {categories.map((cat) => (
            <div key={cat.title} className="rounded-2xl border border-slate-700/50 bg-slate-800/10 overflow-hidden">
              <div className="p-5 flex items-center gap-3 border-b border-slate-700/30">
                <cat.icon size={22} className={cat.color} />
                <h2 className="text-lg font-bold">{cat.title}</h2>
                <span className="text-xs text-slate-500 ml-auto">{cat.items.length} concepts</span>
              </div>
              <div className="divide-y divide-slate-700/20">
                {cat.items.map((item) => (
                  <div key={item.name} className="px-5 py-3 flex gap-4 hover:bg-slate-800/30 transition-colors">
                    <code className={`text-xs font-semibold shrink-0 min-w-[200px] ${cat.color}`}>
                      {item.name}
                    </code>
                    <span className="text-sm text-slate-400">{item.desc}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
      <Footer />
    </>
  );
}
