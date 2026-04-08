"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import { Terminal, Globe, Zap, FolderTree, CheckCircle2 } from "lucide-react";

const files = [
  { name: "Setup-Lab.ps1", desc: "Run first — checks prerequisites, installs Pester 5" },
  { name: "Start-Lab.ps1", desc: "Main entry point (terminal menu or -Web browser)" },
  { name: "lab-server.ps1", desc: "HTTP server for browser UI (REST API + Pester runner)" },
  { name: "lab-ui/index.html", desc: "Browser UI with sidebar, dashboard, terminal, Explain" },
];

const srcFiles = [
  { name: "AzureResourceHelpers.ps1", funcs: "Get-AzureResourceSummary, New-AzureResourceGroup, Get-VMStatus", mock: true },
  { name: "CostMonitorHelpers.ps1", funcs: "Invoke-SafeAzureCall, Send-CostAlert", mock: true },
  { name: "DataProcessing.ps1", funcs: "Test-InputValidation, Split-DataIntoChunks, Process-DataChunk, Get-ProcessedData", mock: false },
  { name: "PSCodeModuleExtracts.ps1", funcs: "Deploy-AzureResourceWithValidation, AzureResource class, AzureVirtualMachine class", mock: true },
  { name: "PSCodeModulesAdditional.ps1", funcs: "Get-AzureResourceInsights, Test-GitEnvironment, Deploy-ResourceGroup, Get-AzureResourceCount, Invoke-ParallelWork", mock: true },
];

const modes = [
  {
    icon: Terminal,
    title: "Terminal Mode",
    desc: "Interactive menu — type 1–9 to run modules, A for all, C for coverage. Step-by-step colored output.",
    cmd: ".\\Start-Lab.ps1",
  },
  {
    icon: Globe,
    title: "Browser Mode",
    desc: "Full web UI at localhost:8080 — sidebar, dashboard, View Source, Explain button, run individual tests.",
    cmd: ".\\Start-Lab.ps1 -Web",
  },
  {
    icon: Zap,
    title: "Direct Pester",
    desc: "Run Invoke-Pester directly with -Output Detailed or New-PesterConfiguration for full control.",
    cmd: "Invoke-Pester ./tests -Output Detailed",
  },
];

export default function LabPage() {
  return (
    <>
      <Nav />
      <div className="max-w-5xl mx-auto px-4 py-16">
        <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">Hands-On</div>
        <h1 className="text-3xl font-extrabold mb-2">Interactive Pester Lab</h1>
        <p className="text-slate-400 mb-10 max-w-2xl">
          96 Pester tests across 9 modules. Every test has inline <code className="text-violet-400 bg-violet-500/10 px-1.5 py-0.5 rounded text-xs"># PESTER ▶</code> comments
          explaining each construct. Run them in the terminal, browser, or directly.
        </p>

        {/* Quick Start */}
        <h2 className="text-xl font-bold mb-4">Quick Start</h2>
        <div className="bg-[#0d1117] border border-slate-700 rounded-xl p-6 font-mono text-sm leading-relaxed mb-12">
          <div className="text-slate-500"># 1. Check prerequisites (installs Pester 5 if needed)</div>
          <div><span className="text-violet-400">cd</span> Pester-Delivery/Day-1/Pester-Lab-Day1</div>
          <div><span className="text-cyan-400">.\Setup-Lab.ps1</span></div>
          <br />
          <div className="text-slate-500"># 2. Launch the lab</div>
          <div><span className="text-cyan-400">.\Start-Lab.ps1</span>          <span className="text-slate-500"># Terminal mode</span></div>
          <div><span className="text-cyan-400">.\Start-Lab.ps1</span> <span className="text-orange-400">-Web</span>     <span className="text-slate-500"># Browser mode (localhost:8080)</span></div>
        </div>

        {/* Three modes */}
        <h2 className="text-xl font-bold mb-4">Three Ways to Run</h2>
        <div className="grid md:grid-cols-3 gap-4 mb-12">
          {modes.map((m) => (
            <div key={m.title} className="p-5 rounded-xl border border-slate-700/50 bg-slate-800/20">
              <m.icon size={24} className="text-violet-400 mb-3" />
              <h3 className="font-semibold mb-2">{m.title}</h3>
              <p className="text-sm text-slate-400 mb-3">{m.desc}</p>
              <code className="text-xs text-cyan-400 bg-slate-900 px-2 py-1 rounded">{m.cmd}</code>
            </div>
          ))}
        </div>

        {/* Source Files */}
        <h2 className="text-xl font-bold mb-4">Source Files (src/)</h2>
        <div className="overflow-x-auto mb-12">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-xs uppercase tracking-wider text-violet-400">
                <th className="p-3 bg-violet-500/5">File</th>
                <th className="p-3 bg-violet-500/5">Functions</th>
                <th className="p-3 bg-violet-500/5">Mocking</th>
              </tr>
            </thead>
            <tbody>
              {srcFiles.map((f) => (
                <tr key={f.name} className="border-t border-slate-800">
                  <td className="p-3 font-mono text-xs text-cyan-400">{f.name}</td>
                  <td className="p-3 text-slate-400 text-xs">{f.funcs}</td>
                  <td className="p-3">
                    {f.mock ? (
                      <span className="text-xs px-2 py-0.5 rounded-full bg-yellow-500/10 text-yellow-400 border border-yellow-500/20">Required</span>
                    ) : (
                      <span className="text-xs px-2 py-0.5 rounded-full bg-green-500/10 text-green-400 border border-green-500/20">Pure — none</span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Lab Files */}
        <h2 className="text-xl font-bold mb-4">Lab Infrastructure</h2>
        <div className="grid md:grid-cols-2 gap-3 mb-12">
          {files.map((f) => (
            <div key={f.name} className="flex items-start gap-3 p-4 rounded-xl border border-slate-700/30 bg-slate-800/10">
              <FolderTree size={16} className="text-cyan-400 mt-0.5 shrink-0" />
              <div>
                <div className="font-mono text-sm text-cyan-400">{f.name}</div>
                <div className="text-xs text-slate-400">{f.desc}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Browser features */}
        <h2 className="text-xl font-bold mb-4">Browser UI Features</h2>
        <div className="grid md:grid-cols-2 gap-3">
          {[
            ["Sidebar", "9 modules with progress tracker (✓ turns green on pass)"],
            ["View Source", "Test file with syntax-highlighted line numbers"],
            ["Expand test", "Click any test to see its code with keyword highlighting"],
            ["Explain", "Identifies every Pester concept used in the test"],
            ["Run one test", "Run a single test by clicking ▶ on any expanded test"],
            ["Dashboard", "Live pass/fail/total/coverage counters"],
            ["Terminal pane", "Colored [+]/[-] output with timing"],
            ["Test Execution Log", "Write-Host output from inside test functions"],
          ].map(([title, desc]) => (
            <div key={title} className="flex items-start gap-3 p-3 rounded-lg border border-slate-700/20">
              <CheckCircle2 size={14} className="text-green-400 mt-0.5 shrink-0" />
              <div>
                <span className="text-sm font-medium">{title}</span>
                <span className="text-xs text-slate-400 ml-2">{desc}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
      <Footer />
    </>
  );
}
