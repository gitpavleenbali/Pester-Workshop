"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import dynamic from "next/dynamic";
import Link from "next/link";
import {
  FlaskConical, BookOpen, Code2, GitCompare, Layers,
  CheckCircle2, XCircle, Zap, Shield, BarChart3,
  ArrowRight, Terminal, Globe, Cpu
} from "lucide-react";

const Mermaid = dynamic(() => import("@/components/Mermaid"), { ssr: false });

const stats = [
  { val: "3", label: "Knowledge Modules", color: "text-violet-400" },
  { val: "107", label: "Pester Tests", color: "text-green-400" },
  { val: "9", label: "PowerShell Sources", color: "text-blue-400" },
  { val: "5", label: "Azure Scenarios", color: "text-cyan-400" },
  { val: "15+", label: "Mermaid Diagrams", color: "text-yellow-400" },
];

const features = [
  {
    icon: BookOpen, title: "Workshop Modules",
    desc: "3 enriched presentations with collapsible sections, Mermaid diagrams, and external references from pester.dev, Microsoft, and Martin Fowler.",
    href: "/modules",
  },
  {
    icon: FlaskConical, title: "Interactive Lab",
    desc: "107 annotated Pester tests with inline # PESTER ▶ comments. Run in terminal, browser UI, or directly with Invoke-Pester.",
    href: "/lab",
  },
  {
    icon: Code2, title: "PSCode Modules",
    desc: "9 progressive PowerShell modules from fundamentals to Azure automation — each with a corresponding Pester test file.",
    href: "/pscode",
  },
  {
    icon: GitCompare, title: "1:1 Test Mapping",
    desc: "Complete traceability from PSCode → tests/ with 1:1 function-level mapping and mocking strategy.",
    href: "/mapping",
  },
  {
    icon: Layers, title: "Pester Concepts",
    desc: "Comprehensive reference covering assertions, mocking, data-driven testing, isolation, and enterprise CI/CD patterns.",
    href: "/concepts",
  },
  {
    icon: BarChart3, title: "Code Coverage",
    desc: "Built-in coverage analysis with JaCoCo export, visual progress bars, and configurable thresholds.",
    href: "/lab",
  },
];

export default function Home() {
  return (
    <>
      <Nav />

      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-slate-900 via-indigo-950/40 to-slate-900" />
        <div className="relative max-w-4xl mx-auto px-4 py-24 text-center">
          <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight mb-4 bg-gradient-to-r from-cyan-400 via-violet-400 to-violet-500 bg-clip-text text-transparent">
            Pester Workshop
          </h1>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto mb-8 leading-relaxed">
            A comprehensive 2-day workshop for PowerShell testing with{" "}
            <strong className="text-slate-200">Pester 5</strong> — the ubiquitous
            test and mock framework for PowerShell.
          </p>

          <div className="flex gap-2 justify-center flex-wrap mb-10">
            {[
              { text: "Pester 5.x", icon: "🧪" },
              { text: "PowerShell 5.1 / 7.x", icon: "⚡" },
              { text: "107 Tests", icon: "✅" },
              { text: "Azure Scenarios", icon: "☁️" },
            ].map((b) => (
              <span key={b.text} className="inline-flex items-center gap-1.5 px-4 py-1.5 text-xs font-semibold rounded-full bg-gradient-to-r from-slate-800/80 to-slate-800/40 border border-slate-600/40 text-slate-200 backdrop-blur-sm shadow-sm">
                <span>{b.icon}</span> {b.text}
              </span>
            ))}
          </div>

          <div className="flex gap-3 justify-center flex-wrap">
            <Link href="/lab" className="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-violet-600 hover:bg-violet-500 text-white font-bold text-sm transition-colors">
              <FlaskConical size={16} /> Check the Lab
            </Link>
            <a href="https://github.com/gitpavleenbali/Pester-Workshop" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-slate-800 hover:bg-slate-700 border border-slate-600 text-white font-bold text-sm transition-colors">
              <GitCompare size={16} /> Clone Pester Workshop
            </a>
            <a href="https://pester.dev" target="_blank" rel="noopener noreferrer" className="inline-flex items-center gap-2 px-6 py-3 rounded-lg border border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10 font-semibold text-sm transition-colors">
              pester.dev <ArrowRight size={14} />
            </a>
          </div>
        </div>
      </section>

      {/* Quick Start — first thing after hero */}
      <section className="border-y border-slate-800 bg-slate-900/40">
        <div className="max-w-4xl mx-auto px-4 py-16">
          <h2 className="text-2xl font-bold mb-6">Quick Start</h2>
          <div className="bg-[#0d1117] border border-slate-700 rounded-xl p-6 font-mono text-sm leading-relaxed">
            <div className="text-slate-500"># 1. Clone the repository</div>
            <div><span className="text-cyan-400">git clone</span> https://github.com/gitpavleenbali/Pester-Workshop.git</div>
            <div><span className="text-violet-400">cd</span> Pester-Workshop</div>
            <br />
            <div className="text-slate-500"># 2. Set up the lab environment</div>
            <div><span className="text-violet-400">cd</span> Pester-Delivery/Day-1/Pester-Lab-Day1</div>
            <div><span className="text-cyan-400">.\Setup-Lab.ps1</span></div>
            <br />
            <div className="text-slate-500"># 3. Launch the lab</div>
            <div><span className="text-cyan-400">.\Start-Lab.ps1</span>          <span className="text-slate-500"># Terminal mode</span></div>
            <div><span className="text-cyan-400">.\Start-Lab.ps1</span> <span className="text-orange-400">-Web</span>     <span className="text-slate-500"># Browser mode (localhost:8080)</span></div>
            <br />
            <div className="text-slate-500"># 4. Run tests directly</div>
            <div><span className="text-cyan-400">Invoke-Pester</span> ./tests <span className="text-orange-400">-Output</span> Detailed</div>
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="bg-slate-900/30">
        <div className="max-w-5xl mx-auto px-4 py-10">
          <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
            {stats.map((s) => (
              <div key={s.label} className="text-center p-5 rounded-2xl bg-gradient-to-b from-slate-800/50 to-slate-800/20 border border-slate-700/30 shadow-lg">
                <div className={`text-4xl font-extrabold ${s.color}`}>{s.val}</div>
                <div className="text-[10px] uppercase tracking-wider text-slate-500 mt-1.5 font-semibold">{s.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Architecture diagram */}
      <section className="max-w-5xl mx-auto px-4 py-16">
        <h2 className="text-2xl font-bold mb-2">Architecture</h2>
        <p className="text-slate-400 text-sm mb-6">How PSCode modules flow into testable source files, Pester tests, and the interactive lab.</p>
        <Mermaid chart={`graph TB
    subgraph INPUT["Source Material"]
        direction LR
        PS["PSCode/<br/>9 PowerShell Modules"]
        MOD["Modules/<br/>3 Knowledge Decks"]
    end
    subgraph ENGINE["Test Engine"]
        direction LR
        SRC["PSCode/<br/>9 Source Files"]
        TST["tests/<br/>9 Pester Files<br/>107 Tests"]
    end
    subgraph OUTPUT["Delivery"]
        direction LR
        TERM["Terminal Lab<br/>Interactive Menu"]
        WEB["Browser Lab<br/>localhost:8080"]
        SITE["Workshop Website<br/>GitHub Pages"]
    end
    PS --> SRC
    SRC --> TST
    MOD --> SITE
    TST --> TERM
    TST --> WEB
    style INPUT fill:#0f172a,stroke:#818cf8,color:#f8fafc,stroke-width:2px
    style ENGINE fill:#0f172a,stroke:#22c55e,color:#f8fafc,stroke-width:2px
    style OUTPUT fill:#0f172a,stroke:#06b6d4,color:#f8fafc,stroke-width:2px
    style PS fill:#1e1b4b,stroke:#818cf8,color:#f8fafc
    style MOD fill:#1e1b4b,stroke:#a78bfa,color:#f8fafc
    style SRC fill:#1e293b,stroke:#8b5cf6,color:#f8fafc
    style TST fill:#052e16,stroke:#22c55e,color:#f8fafc
    style TERM fill:#0c4a6e,stroke:#06b6d4,color:#f8fafc
    style WEB fill:#0c4a6e,stroke:#06b6d4,color:#f8fafc
    style SITE fill:#0c4a6e,stroke:#38bdf8,color:#f8fafc`}
        />
      </section>

      {/* Features grid */}
      <section className="max-w-5xl mx-auto px-4 pb-20">
        <h2 className="text-2xl font-bold mb-2">What&apos;s Inside</h2>
        <p className="text-slate-400 text-sm mb-8">Everything you need to learn and teach PowerShell testing at enterprise scale.</p>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {features.map((f) => (
            <Link
              key={f.title}
              href={f.href}
              className="group p-6 rounded-xl border border-slate-700/50 bg-slate-800/20 hover:border-violet-500/30 hover:bg-violet-500/5 transition-all"
            >
              <f.icon size={28} className="text-violet-400 mb-3 group-hover:scale-110 transition-transform" />
              <h3 className="font-semibold text-base mb-2">{f.title}</h3>
              <p className="text-sm text-slate-400 leading-relaxed">{f.desc}</p>
            </Link>
          ))}
        </div>
      </section>



      <Footer />
    </>
  );
}
