"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import DocsSidebar from "@/components/DocsSidebar";
import { CheckCircle2, AlertTriangle, XCircle } from "lucide-react";

const mapping = [
  { num: "01", module: "Knowledge Refresh", src: "Azure-Cloud-Analyzer.ps1", funcs: ["Get-AzureResourceInsights"], test: "PSCode-01", count: 5, mock: "Mock Get-AzResource", status: "match" },
  { num: "02", module: "Advanced Functions", src: "Azure-Resource-Manager.ps1", funcs: ["Get-AzureResourceSummary", "New-AzureResourceGroup", "Get-VMStatus"], test: "PSCode-02", count: 18, mock: "-ParameterFilter", status: "match" },
  { num: "03", module: "Parameters", src: "Azure-Parameter-Mastery.ps1", funcs: ["(dot-sources Module 02)"], test: "PSCode-03", count: 10, mock: "ValidateSet, HaveParameter", status: "match" },
  { num: "04", module: "Classes", src: "Azure-Classes.ps1", funcs: ["AzureResource", "AzureVirtualMachine", "Deploy-AzureResourceWithValidation"], test: "PSCode-04", count: 16, mock: "None (pure OOP)", status: "match" },
  { num: "05", module: "Error Handling", src: "Azure-Error-Handling.ps1", funcs: ["(dot-sources Module 04)"], test: "PSCode-05", count: 7, mock: "Should -Throw, -Verifiable", status: "match" },
  { num: "06", module: "Debugging", src: "Debug-Demo.ps1", funcs: ["Test-InputValidation", "Split-DataIntoChunks", "Process-DataChunk", "Get-ProcessedData"], test: "PSCode-06", count: 17, mock: "None (pure funcs)", status: "match" },
  { num: "07", module: "Git Integration", src: "Azure-Git-Training.ps1", funcs: ["Test-GitEnvironment", "Deploy-ResourceGroup"], test: "PSCode-07", count: 9, mock: "Mock native git", status: "match" },
  { num: "08", module: "Runspaces", src: "Azure-Runspaces.ps1", funcs: ["Get-AzureResourceCount", "Invoke-ParallelWork"], test: "PSCode-08", count: 9, mock: "None (pure funcs)", status: "match" },
  { num: "09", module: "Capstone", src: "Azure-Cost-Monitor.ps1", funcs: ["Invoke-SafeAzureCall", "Send-CostAlert", "Get-VMStatus"], test: "PSCode-09", count: 16, mock: "Boundary, $script:", status: "match" },
];

// No phantom functions — all functions live in their PSCode module directly

export default function MappingPage() {
  return (
    <>
      <Nav />
      <div className="flex min-h-[calc(100vh-56px)]">
        <DocsSidebar />
      <div className="flex-1 max-w-6xl px-4 py-16">
        <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">Complete Traceability</div>
        <h1 className="text-3xl font-extrabold mb-2">PSCode → Source → Test Mapping</h1>
        <p className="text-slate-400 mb-10 max-w-2xl">
          1:1 mapping showing how each PSCode module maps to its Pester test file.
          Each test dot-sources the PSCode .ps1 file directly — zero duplication.
        </p>

        {/* Main mapping table */}
        <div className="overflow-x-auto mb-16">
          <table className="w-full text-sm">
            <thead>
              <tr className="text-left text-[10px] uppercase tracking-wider text-violet-400 border-b-2 border-slate-700">
                <th className="p-3 bg-violet-500/5">#</th>
                <th className="p-3 bg-violet-500/5">PSCode Module</th>
                <th className="p-3 bg-violet-500/5">Source File</th>
                <th className="p-3 bg-violet-500/5">Functions Tested</th>
                <th className="p-3 bg-violet-500/5">Test File</th>
                <th className="p-3 bg-violet-500/5 text-center">Tests</th>
                <th className="p-3 bg-violet-500/5">Mocking</th>
                <th className="p-3 bg-violet-500/5 text-center">Status</th>
              </tr>
            </thead>
            <tbody>
              {mapping.map((m) => (
                <tr key={m.num} className="border-t border-slate-800 hover:bg-slate-800/30">
                  <td className="p-3 font-extrabold text-violet-400">{m.num}</td>
                  <td className="p-3 font-medium">{m.module}</td>
                  <td className="p-3 font-mono text-xs text-cyan-400/80">{m.src}</td>
                  <td className="p-3 font-mono text-xs text-slate-300">
                    {m.funcs.map((f) => (
                      <div key={f} className={f.endsWith("*") || f.endsWith("†") ? "text-yellow-400" : ""}>
                        {f}
                      </div>
                    ))}
                  </td>
                  <td className="p-3 font-mono text-xs text-slate-400">{m.test}</td>
                  <td className="p-3 text-center font-bold text-green-400">{m.count}</td>
                  <td className="p-3 text-xs text-violet-300">{m.mock}</td>
                  <td className="p-3 text-center">
                    {m.status === "match" ? (
                      <CheckCircle2 size={16} className="text-green-400 mx-auto" />
                    ) : (
                      <AlertTriangle size={16} className="text-yellow-400 mx-auto" />
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Totals */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-16">
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-green-400">107</div>
            <div className="text-[10px] uppercase text-slate-500">Total Tests</div>
          </div>
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-blue-400">9</div>
            <div className="text-[10px] uppercase text-slate-500">Test Files</div>
          </div>
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-green-400">9</div>
            <div className="text-[10px] uppercase text-slate-500">Clean 1:1 Matches</div>
          </div>
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-violet-400">85.8%</div>
            <div className="text-[10px] uppercase text-slate-500">Code Coverage</div>
          </div>
        </div>

        {/* Phantom functions */}
        <h2 className="text-xl font-bold mb-4">Architecture Note</h2>
        <div className="p-4 rounded-xl border border-green-500/20 bg-green-500/5">
          <div className="flex items-start gap-3">
            <CheckCircle2 size={16} className="text-green-400 mt-0.5 shrink-0" />
            <div className="text-sm text-slate-400">
              <span className="text-green-400 font-semibold">Zero duplication.</span> Each test file dot-sources its PSCode .ps1 file directly in <code className="text-violet-400">BeforeAll</code>. 
              Modules 03 and 05 dot-source their upstream module (02 and 04 respectively) so every folder has its own entry point.
            </div>
          </div>
        </div>
      </div>
      </div>
      <Footer />
    </>
  );
}
