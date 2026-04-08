"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";
import { CheckCircle2, AlertTriangle, XCircle } from "lucide-react";

const mapping = [
  { num: "01", module: "Knowledge Refresh", src: "PSCodeModulesAdditional.ps1", funcs: ["Get-AzureResourceInsights"], test: "PSCode-01", count: 5, mock: "Mock Get-AzResource", status: "match" },
  { num: "02", module: "Advanced Functions", src: "AzureResourceHelpers.ps1", funcs: ["Get-AzureResourceSummary", "New-AzureResourceGroup", "Get-VMStatus*"], test: "PSCode-02", count: 18, mock: "-ParameterFilter", status: "partial" },
  { num: "03", module: "Parameters", src: "AzureResourceHelpers.ps1", funcs: ["New-AzureResourceGroup†"], test: "PSCode-03", count: 5, mock: "ValidateSet, Mandatory", status: "partial" },
  { num: "04", module: "Classes", src: "PSCodeModuleExtracts.ps1", funcs: ["AzureResource", "AzureVirtualMachine"], test: "PSCode-04", count: 15, mock: "None (pure OOP)", status: "match" },
  { num: "05", module: "Error Handling", src: "PSCodeModuleExtracts.ps1", funcs: ["Deploy-AzureResourceWithValidation"], test: "PSCode-05", count: 6, mock: "Should -Throw, override", status: "match" },
  { num: "06", module: "Debugging", src: "DataProcessing.ps1", funcs: ["Test-InputValidation", "Split-DataIntoChunks", "Process-DataChunk", "Get-ProcessedData"], test: "PSCode-06", count: 16, mock: "None (pure funcs)", status: "match" },
  { num: "07", module: "Git Integration", src: "PSCodeModulesAdditional.ps1", funcs: ["Test-GitEnvironment*", "Deploy-ResourceGroup"], test: "PSCode-07", count: 9, mock: "Mock native git", status: "partial" },
  { num: "08", module: "Runspaces", src: "PSCodeModulesAdditional.ps1", funcs: ["Get-AzureResourceCount", "Invoke-ParallelWork*"], test: "PSCode-08", count: 8, mock: "None (pure funcs)", status: "partial" },
  { num: "09", module: "Capstone", src: "CostMonitorHelpers.ps1", funcs: ["Invoke-SafeAzureCall", "Send-CostAlert*", "Get-VMStatus*"], test: "PSCode-09", count: 14, mock: "Boundary, $script:", status: "partial" },
];

const phantoms = [
  { func: "Get-VMStatus", src: "AzureResourceHelpers.ps1", tests: "PSCode-02, PSCode-09", reason: "Created to demonstrate -ParameterFilter mocking with multiple VM states" },
  { func: "Send-CostAlert", src: "CostMonitorHelpers.ps1", tests: "PSCode-09", reason: "Created to demonstrate Mock Send-MailMessage and boundary -TestCases" },
  { func: "Invoke-ParallelWork", src: "PSCodeModulesAdditional.ps1", tests: "PSCode-08", reason: "Created to demonstrate array processing and edge case testing" },
  { func: "Test-GitEnvironment", src: "PSCodeModulesAdditional.ps1", tests: "PSCode-07", reason: "Rewritten from Initialize-GitEnvironment for testability" },
];

export default function MappingPage() {
  return (
    <>
      <Nav />
      <div className="max-w-6xl mx-auto px-4 py-16">
        <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">Complete Traceability</div>
        <h1 className="text-3xl font-extrabold mb-2">PSCode → Source → Test Mapping</h1>
        <p className="text-slate-400 mb-10 max-w-2xl">
          Audited 1:1 mapping showing how each PSCode module flows through source extraction to Pester tests.
          Functions marked with <span className="text-yellow-400">*</span> are lab-only additions (not from PSCode).
          <span className="text-yellow-400">†</span> means cross-module reference.
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
            <div className="text-2xl font-extrabold text-green-400">96</div>
            <div className="text-[10px] uppercase text-slate-500">Total Tests</div>
          </div>
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-blue-400">9</div>
            <div className="text-[10px] uppercase text-slate-500">Test Files</div>
          </div>
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-green-400">6</div>
            <div className="text-[10px] uppercase text-slate-500">Clean 1:1 Matches</div>
          </div>
          <div className="p-4 rounded-xl bg-slate-800/30 border border-slate-700/30 text-center">
            <div className="text-2xl font-extrabold text-yellow-400">4</div>
            <div className="text-[10px] uppercase text-slate-500">Lab-Only Functions</div>
          </div>
        </div>

        {/* Phantom functions */}
        <h2 className="text-xl font-bold mb-4">Lab-Only Functions (Not from PSCode)</h2>
        <p className="text-slate-400 text-sm mb-6">
          These 4 functions were created specifically for the Pester lab to demonstrate testing patterns that
          the original PSCode modules didn&apos;t cover well enough.
        </p>
        <div className="space-y-3">
          {phantoms.map((p) => (
            <div key={p.func} className="flex items-start gap-3 p-4 rounded-xl border border-yellow-500/20 bg-yellow-500/5">
              <AlertTriangle size={16} className="text-yellow-400 mt-0.5 shrink-0" />
              <div>
                <div className="font-mono text-sm text-yellow-400 font-semibold">{p.func}</div>
                <div className="text-xs text-slate-400 mt-1">
                  <span className="text-slate-500">src/</span>{p.src} · tested in {p.tests}
                </div>
                <div className="text-xs text-slate-400 mt-1">{p.reason}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <Footer />
    </>
  );
}
