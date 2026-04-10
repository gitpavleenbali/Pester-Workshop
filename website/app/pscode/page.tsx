"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import DocsSidebar from "@/components/DocsSidebar";

const GITHUB_BASE = "https://github.com/gitpavleenbali/Pester-Workshop/blob/master/Pester-Delivery/PSCode-Source";

const modules = [
  { num: "01", name: "Knowledge Refresh", file: "Azure-Cloud-Analyzer.ps1", folder: "01_knowledge_refresh", difficulty: "Beginner", desc: "Cmdlets, arrays, pipeline, objects — Azure resource analysis", tags: ["Mock Get-AzResource", "Should -Be"] },
  { num: "02", name: "Advanced Functions", file: "Azure-Resource-Manager.ps1", folder: "02_advanced_functions", difficulty: "Beginner+", desc: "Function design, parameters, help, output objects for Azure management", tags: ["-ParameterFilter", "-TestCases", "Should -Throw"] },
  { num: "03", name: "Mastering Parameters", file: "Azure-Parameter-Mastery.ps1", folder: "03_mastering_parameters", difficulty: "Intermediate", desc: "ValidateSet, Mandatory, parameter sets — dot-sources Module 02", tags: ["ValidateSet", "Should -HaveParameter", "BeTrue/BeFalse"] },
  { num: "04", name: "PowerShell Classes", file: "Azure-Classes.ps1", folder: "04_powershell_classes", difficulty: "Intermediate", desc: "OOP, constructors, methods, inheritance with Azure resource classes", tags: ["No mocking", "State transitions", "-TestCases"] },
  { num: "05", name: "Error Handling", file: "Azure-Error-Handling.ps1", folder: "05_error_handling", difficulty: "Intermediate+", desc: "Try/catch, error recovery, input validation — dot-sources Module 04", tags: ["Should -Throw '*pattern*'", "-Verifiable", "InvokeVerifiable"] },
  { num: "06", name: "Debugging", file: "Debug-Demo.ps1", folder: "06_debugging", difficulty: "Intermediate+", desc: "Data processing pipeline, pure functions, TestDrive:", tags: ["Pure functions", "-TestCases", "Should -Match", "TestDrive:"] },
  { num: "07", name: "Git Integration", file: "Azure-Git-Training.ps1", folder: "07_git_integration", difficulty: "Advanced", desc: "Version control, branching, CI/CD with PowerShell and Azure", tags: ["Mock native git", "-Times 0", "Context scopes"] },
  { num: "08", name: "Runspaces", file: "Azure-Runspaces.ps1", folder: "08_runspaces", difficulty: "Advanced", desc: "Parallel execution, thread safety, concurrent Azure operations", tags: ["Pure functions", "Should -HaveCount", "Edge cases"] },
  { num: "09", name: "Capstone", file: "Azure-Cost-Monitor.ps1", folder: "09_final_solution_apply_learnings", difficulty: "Expert", desc: "Real-world cost monitoring integrating all 8 prior modules", tags: ["Boundary testing", "$script: scope", "-Skip", "Set-ItResult"] },
];

const diffColors: Record<string, string> = {
  "Beginner": "text-green-400 bg-green-500/10 border-green-500/20",
  "Beginner+": "text-green-400 bg-green-500/10 border-green-500/20",
  "Intermediate": "text-blue-400 bg-blue-500/10 border-blue-500/20",
  "Intermediate+": "text-blue-400 bg-blue-500/10 border-blue-500/20",
  "Advanced": "text-yellow-400 bg-yellow-500/10 border-yellow-500/20",
  "Expert": "text-red-400 bg-red-500/10 border-red-500/20",
};

export default function PSCodePage() {
  return (
    <>
      <Nav />
      <div className="flex min-h-[calc(100vh-56px)]">
        <DocsSidebar />
      <div className="flex-1 max-w-5xl px-4 py-16">
        <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">Source Material</div>
        <h1 className="text-3xl font-extrabold mb-2">PSCode — PowerShell Training Modules</h1>
        <p className="text-slate-400 mb-10 max-w-2xl">
          9 progressive modules from PowerShell fundamentals to Azure automation expertise.
          Each module has a corresponding Pester test file with 1:1 function mapping.
        </p>

        <div className="space-y-4">
          {modules.map((m) => (
            <a
              key={m.num}
              href={`${GITHUB_BASE}/${m.folder}/${m.file}`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex gap-5 p-5 rounded-xl border border-slate-700/50 bg-slate-800/20 hover:border-violet-500/30 transition-colors group"
            >
              <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-violet-500/20 to-blue-500/20 flex items-center justify-center text-xl font-extrabold text-violet-400 shrink-0">
                {m.num}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-3 mb-1 flex-wrap">
                  <h3 className="font-bold">{m.name}</h3>
                  <span className={`text-[10px] px-2 py-0.5 rounded-full border font-semibold ${diffColors[m.difficulty]}`}>
                    {m.difficulty}
                  </span>
                </div>
                <p className="text-sm text-slate-400 mb-2">{m.desc}</p>
                <div className="flex items-center gap-2 flex-wrap">
                  <span className="text-xs font-mono text-cyan-400/70">{m.file}</span>
                  <span className="text-slate-600">·</span>
                  {m.tags.map((t) => (
                    <span key={t} className="text-[10px] px-2 py-0.5 rounded-full bg-slate-700/50 text-slate-400 border border-slate-600/30">
                      {t}
                    </span>
                  ))}
                </div>
              </div>
            </a>
          ))}
        </div>
      </div>
      </div>
      <Footer />
    </>
  );
}
