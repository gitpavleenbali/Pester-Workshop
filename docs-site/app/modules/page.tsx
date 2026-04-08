"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import dynamic from "next/dynamic";
import { BookOpen, Clock, ChevronDown } from "lucide-react";

const Mermaid = dynamic(() => import("@/components/Mermaid"), { ssr: false });

const modules = [
  {
    num: "01",
    title: "Fundamentals of Unit Testing — Introduction & Context",
    duration: "~60 min",
    sections: 18,
    lines: 477,
    topics: [
      "What is Software Testing",
      "Types of Testing (Unit, Integration, E2E, Smoke, Regression)",
      "Microsoft DevOps Test Taxonomy (L0–L4)",
      "Testing Pyramid",
      "Why Unit Testing Matters — FIRST Principles",
      "Unit vs Integration Testing",
      "AAA Pattern (Arrange, Act, Assert)",
      "Why Testing PowerShell in the Enterprise",
      "What Is Pester — 5 Core Capabilities",
      "Where Pester Fits in DevOps",
      "Pester Test Structure — Describe, Context, It",
      "Setup & Teardown Lifecycle",
      "Discovery vs Execution Phases",
      "Common Assertion Operators (13 operators)",
      "Pester 4 vs Pester 5 — What Changed",
      "VS Code Integration",
      "Running Pester — Essential Commands",
      "Quick Example",
    ],
    diagram: `graph LR
    A[Write Code] --> B[Write Tests]
    B --> C[Run Tests]
    C --> D{Pass?}
    D -- Yes --> E[Ship]
    D -- No --> F[Fix]
    F --> B
    style A fill:#1e293b,stroke:#334155,color:#f8fafc
    style E fill:#065f46,stroke:#10b981,color:#f8fafc
    style F fill:#7f1d1d,stroke:#ef4444,color:#f8fafc`,
  },
  {
    num: "02",
    title: "Enterprise Positioning — Pester Architecture for Large Organizations",
    duration: "~30 min",
    sections: 14,
    lines: 493,
    topics: [
      "Testing at Enterprise Scale",
      "Microsoft DevOps Test Principles (Shift Left)",
      "Repository Structure (src/ + tests/)",
      "Separation of Production Code and Tests",
      "Pester Test Structure — Deep Dive",
      "Common Assertion Operators",
      "Local Execution vs CI Execution",
      "New-PesterConfiguration for CI",
      "GitHub Actions Workflow (ready-to-use YAML)",
      "Governance & Standardization Checklist",
      "Do's and Don'ts — Best Practices",
      "Gaps, Limitations & Mitigations",
      "Complementary Enterprise Tools",
      "Key Metrics & Enterprise Maturity Model (Level 0–4)",
    ],
    diagram: `graph LR
    DEV[Developer] --> TEST[Pester Tests]
    TEST --> PUSH[Git Push]
    PUSH --> CI[CI Pipeline]
    CI --> GATE{Quality Gate}
    GATE -- Pass --> DEPLOY[Deploy]
    GATE -- Fail --> FIX[Feedback]
    FIX --> DEV
    style TEST fill:#065f46,stroke:#10b981,color:#f8fafc
    style CI fill:#312e81,stroke:#818cf8,color:#f8fafc
    style GATE fill:#78350f,stroke:#f59e0b,color:#f8fafc`,
  },
  {
    num: "03",
    title: "Mocking & Test Isolation",
    duration: "~30 min",
    sections: 17,
    lines: 466,
    topics: [
      "The Problem — Why You Can't Just Run the Code",
      "What Is Mocking — Mock vs Stub vs Fake",
      "Pester Mocking — Mock + Should -Invoke",
      "Real-World Examples (Azure, AD, REST, git)",
      "Mock Scoping — Pester 5 Rules",
      "ParameterFilter — Conditional Mocks",
      "Verifiable Mocks",
      "Mocking Module Functions (-ModuleName)",
      "$PesterBoundParameters (Pester 5.2+)",
      "TestDrive:\\ — Temporary File System",
      "TestRegistry:\\ — Temporary Registry",
      "Testing Behavior, Not Side Effects",
      "Cmdlets You Should Always Mock",
      "Testing .NET / C# Code with Pester",
      "Binary Module Limitations",
      "Common Mocking Mistakes",
      "When NOT to Mock",
    ],
    diagram: `graph LR
    subgraph WITHOUT[Without Mock]
    F1[Function] --> REAL[Azure API]
    end
    subgraph WITH[With Mock]
    F2[Function] --> MOCK[Fake Data]
    end
    style WITHOUT fill:#0f172a,stroke:#ef4444,color:#f8fafc
    style WITH fill:#0f172a,stroke:#10b981,color:#f8fafc`,
  },
];

export default function ModulesPage() {
  return (
    <>
      <Nav />
      <div className="max-w-5xl mx-auto px-4 py-16">
        <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">Day 1 — Presentation Materials</div>
        <h1 className="text-3xl font-extrabold mb-2">Workshop Modules</h1>
        <p className="text-slate-400 mb-10 max-w-2xl">
          Three enriched presentations with collapsible sections for paced delivery.
          Each section expands on click — no theory overload.
        </p>

        <div className="space-y-8">
          {modules.map((m) => (
            <div key={m.num} className="rounded-2xl border border-slate-700/50 bg-slate-800/20 overflow-hidden">
              {/* Header */}
              <div className="p-6 flex gap-5 items-start">
                <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-violet-500/20 to-blue-500/20 flex items-center justify-center text-2xl font-extrabold text-violet-400 shrink-0">
                  {m.num}
                </div>
                <div className="flex-1 min-w-0">
                  <h2 className="text-lg font-bold mb-1">{m.title}</h2>
                  <div className="flex gap-4 text-xs text-slate-400 mb-3">
                    <span className="flex items-center gap-1"><Clock size={12} /> {m.duration}</span>
                    <span>{m.sections} sections</span>
                    <span>{m.lines} lines</span>
                  </div>

                  {/* Topics */}
                  <div className="flex flex-wrap gap-1.5">
                    {m.topics.map((t) => (
                      <span key={t} className="text-[10px] px-2 py-0.5 rounded-full bg-slate-700/50 text-slate-400 border border-slate-600/30">
                        {t}
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Diagram */}
              <div className="border-t border-slate-700/30 px-6 pb-6">
                <Mermaid chart={m.diagram} />
              </div>
            </div>
          ))}
        </div>
      </div>
      <Footer />
    </>
  );
}
