"use client";

import Nav from "@/components/Nav";
import Footer from "@/components/Footer";

const modules = [
  { id: 1, name: "01 Knowledge Refresh", tests: 5, file: "Azure-Cloud-Analyzer.ps1", funcs: "Get-AzureResourceInsights", pester: "Mock, Should -Be, Should -Invoke" },
  { id: 2, name: "02 Advanced Functions", tests: 18, file: "Azure-Resource-Manager.ps1", funcs: "Get-AzureResourceSummary, New-AzureResourceGroup, Get-VMStatus", pester: "-TestCases, -ParameterFilter, Should -Throw" },
  { id: 3, name: "03 Parameters", tests: 10, file: "Azure-Parameter-Mastery.ps1", funcs: "ValidateSet, Mandatory, Should -HaveParameter", pester: "Should -BeTrue, Should -BeFalse" },
  { id: 4, name: "04 Classes", tests: 16, file: "Azure-Classes.ps1", funcs: "AzureResource, AzureVirtualMachine", pester: "No mocking, State transitions, -TestCases" },
  { id: 5, name: "05 Error Handling", tests: 7, file: "Azure-Error-Handling.ps1", funcs: "Deploy-AzureResourceWithValidation", pester: "Should -Throw, -Verifiable, InvokeVerifiable" },
  { id: 6, name: "06 Debugging", tests: 17, file: "Debug-Demo.ps1", funcs: "Test-InputValidation, Split-DataIntoChunks, Get-ProcessedData", pester: "Pure functions, TestDrive:, -TestCases" },
  { id: 7, name: "07 Git Integration", tests: 9, file: "Azure-Git-Training.ps1", funcs: "Test-GitEnvironment, Deploy-ResourceGroup", pester: "Mock native git, Should -Invoke -Times 0" },
  { id: 8, name: "08 Runspaces", tests: 9, file: "Azure-Runspaces.ps1", funcs: "Get-AzureResourceCount, Invoke-ParallelWork", pester: "Should -HaveCount, edge cases" },
  { id: 9, name: "09 Capstone", tests: 16, file: "Azure-Cost-Monitor.ps1", funcs: "Invoke-SafeAzureCall, Send-CostAlert", pester: "Boundary $script:, -Skip, Set-ItResult" },
];

// Simulated test output per module
const simOutput: Record<number, string> = {
  1: `Pester v5.7.1

Describing Module 01 · Get-AzureResourceInsights
  [+] Returns subscription-wide scope when no RG specified  (12ms)
  [+] Returns correct resource count from mocked data  (8ms)
  [+] Returns correct number of unique types  (6ms)
  [+] Verifies Get-AzResource was called via Should -Invoke  (9ms)
  [+] Returns zero resources for empty subscription  (5ms)

Tests Passed: 5, Failed: 0, Total: 5

── Test Execution Log ──
  → Calling Get-AzureResourceInsights without -ResourceGroupName
  → Mock returns 4 fake resources (2 VMs, 1 Storage, 1 KeyVault)
  → Should -Invoke confirms Get-AzResource was called 1 time`,

  2: `Pester v5.7.1

Describing Module 02 · Get-AzureResourceSummary
  [+] Returns correct resource count  (10ms)
  [+] Returns correct number of unique types  (7ms)
  [+] Returns first resource name  (6ms)
  [+] Sets scope to Subscription-wide when no RG specified  (5ms)
 Context New-AzureResourceGroup
  [+] Creates RG with correct name  (8ms)
  [+] Uses default location (eastus) when not specified  (6ms)
  [+] Sets ProvisioningState to Succeeded  (5ms)
  [+] Rejects invalid location  (11ms)
  [+] Preserves custom tags  (7ms)
 Context Get-VMStatus with ParameterFilter
  [+] Returns Running for a running VM  (9ms)
  [+] Returns Deallocated for a deallocated VM  (6ms)
  [+] Returns Stopped for a stopped VM  (5ms)
  [+] Returns null for a non-existent VM  (4ms)
  [+] Calls Get-AzVM with the correct VM name  (8ms)

Tests Passed: 18, Failed: 0, Total: 18`,

  3: `Pester v5.7.1

Describing Module 03 · Parameter Validation Patterns
 Context ValidateSet
  [+] Accepts valid location from ValidateSet  (7ms)
  [+] Rejects value not in ValidateSet  (9ms)
  [+] Uses default location when omitted  (5ms)
  [+] Uses default tags when omitted  (4ms)
  [+] Name is mandatory  (6ms)
 Context Should -HaveParameter
  [+] Name is Mandatory parameter  (8ms)
  [+] Location is type String  (5ms)
  [+] Location default = eastus  (4ms)
  [+] Should -BeTrue for boolean check  (3ms)
  [+] Should -BeFalse for boolean check  (3ms)

Tests Passed: 10, Failed: 0, Total: 10`,

  4: `Pester v5.7.1

Describing Module 04 · AzureResource Class
  [+] Name = 'my-storage'  (5ms)
  [+] Type is AzureResource  (4ms)
  [+] GetDisplayName() returns Type/Name  (6ms)
  [+] IsInRegion() returns true for match  (4ms)
  [+] AddTag() adds to hashtable  (5ms)
 Context AzureVirtualMachine
  [+] VM size Standard_B1s → 1 core, 1 GB  (6ms)
  [+] VM size Standard_B2s → 2 cores, 4 GB  (5ms)
  [+] VM size Standard_D4s → 4 cores, 16 GB  (4ms)
  [+] VM size Standard_E8s → 2 cores, 8 GB  (4ms)
  [+] State lifecycle: Created -> Running -> Stopped  (7ms)
  [+] EstimateMonthlyCost = CpuCores x 35.50  (5ms)
  [+] Inherits GetDisplayName() from AzureResource  (4ms)

Tests Passed: 16, Failed: 0, Total: 16`,

  5: `Pester v5.7.1

Describing Module 05 · Deploy-AzureResourceWithValidation
  [+] Returns Deployed status  (12ms)
  [+] Validates RG exists before deploying  (9ms)
  [+] Should -InvokeVerifiable passes  (7ms)
  [+] Rejects name < 3 chars  (8ms)
  [+] Rejects special characters in name  (6ms)
  [+] Rejects names with spaces  (5ms)
  [+] Throws when RG does not exist  (9ms)

Tests Passed: 7, Failed: 0, Total: 7`,

  6: `Pester v5.7.1

Describing Module 06 · Data Processing Pipeline
  [+] Returns IsValid=True for good data  (5ms)
  [+] Rejects empty string  (7ms)
  [+] Rejects short strings (< 5 chars)  (6ms)
  [+] Rejects level outside 1-5  (5ms)
  [+] Reports multiple errors at once  (8ms)
  [+] Splits 10-char string into 4 chunks  (6ms)
  [+] First chunk = first N characters  (4ms)
  [+] Last chunk = remainder  (4ms)
  [+] Handles chunk > input length  (3ms)
  [+] Level 1 → UPPERCASE  (5ms)
  [+] Level 2 → lowercase  (4ms)
  [+] Level 3 → replace spaces  (4ms)
  [+] Level 0 → keep original  (3ms)
  [+] Returns result for valid input  (6ms)
  [+] Returns null for invalid input  (5ms)
  [+] Preserves original data  (4ms)
  [+] TestDrive: write and read back  (8ms)

Tests Passed: 17, Failed: 0, Total: 17`,

  7: `Pester v5.7.1

Describing Module 07 · Test-GitEnvironment
  [+] Detects Git is installed  (8ms)
  [+] Reads Git version  (6ms)
  [+] Reads user name  (5ms)
  [+] Reads user email  (5ms)
  [+] Detects repo context  (7ms)
 Context Deploy-ResourceGroup
  [+] Returns Status = Created  (9ms)
  [+] Calls New-AzResourceGroup  (7ms)
  [+] Returns Status = Exists  (6ms)
  [+] Does NOT call New-AzResourceGroup  (5ms)

Tests Passed: 9, Failed: 0, Total: 9`,

  8: `Pester v5.7.1

Describing Module 08 · Get-AzureResourceCount
  [+] Returns formatted message with RG name  (6ms)
  [+] Includes the resource group name  (5ms)
  [+] Works with hyphenated RG names  (4ms)
 Context Invoke-ParallelWork
  [+] Processes all items  (7ms)
  [+] HaveCount assertion for 5 items  (5ms)
  [+] Marks each item as Processed  (6ms)
  [+] Preserves item values  (4ms)
  [+] Returns empty for empty input  (3ms)
  [+] Handles single item  (4ms)

Tests Passed: 9, Failed: 0, Total: 9`,

  9: `Pester v5.7.1

Describing Module 09 · Invoke-SafeAzureCall
  [+] Succeeds on first try  (8ms)
  [+] Fails after max retries  (15ms)
  [+] Retries and recovers from transient error  (12ms)
 Context Send-CostAlert — Boundary Testing
  [+] Cost 10 vs Threshold 100 → AlertSent=False  (5ms)
  [+] Cost 99 vs Threshold 100 → AlertSent=False  (4ms)
  [+] Cost 100 vs Threshold 100 → AlertSent=False  (4ms)
  [+] Cost 100.01 vs Threshold 100 → AlertSent=True  (5ms)
  [+] Cost 101 vs Threshold 100 → AlertSent=True  (4ms)
  [+] Cost 500 vs Threshold 200 → AlertSent=True  (4ms)
  [+] Does NOT call Send-MailMessage below threshold  (6ms)
  [+] Calls Send-MailMessage above threshold  (5ms)
 Context Get-VMStatus — Mocked Azure
  [+] Running VM returns Running  (7ms)
  [+] Stopped VM returns Deallocated  (5ms)
  [+] Missing VM returns null  (4ms)
  [.] Integration test: real Azure VM status check  (skipped)
  [+] Conditional skip based on environment  (3ms)

Tests Passed: 15, Failed: 0, Skipped: 1, Total: 16`,
};

export default function SimulationPage() {
  return (
    <>
      <Nav />
      <div className="max-w-6xl mx-auto px-4 py-10">
        <div className="text-xs uppercase tracking-widest text-cyan-400 font-bold mb-1">Interactive</div>
        <h1 className="text-3xl font-extrabold mb-2">Lab Simulation</h1>
        <p className="text-slate-400 mb-2 max-w-3xl">
          This is a <span className="text-yellow-400 font-semibold">read-only simulation</span> of the Pester Lab browser UI.
          Click any module to see simulated test output. To run real tests, use the actual lab:
        </p>
        <code className="text-xs text-cyan-400 bg-slate-900 px-3 py-1.5 rounded inline-block mb-8">
          cd Pester-Delivery/Day-1/Pester-Lab-Day1 &amp;&amp; .\Start-Lab.ps1 -Web
        </code>

        <div className="flex gap-4" style={{height: 'calc(100vh - 250px)', minHeight: '500px'}}>
          {/* Sidebar */}
          <div className="w-56 bg-[#0d1220] border border-slate-700 rounded-xl flex flex-col shrink-0 overflow-hidden">
            <div className="px-3 py-2 text-[9px] uppercase tracking-widest text-slate-500 font-bold border-b border-slate-800">PSCode Modules</div>
            <div className="flex-1 overflow-y-auto" id="sim-sidebar">
              {modules.map((m) => (
                <button
                  key={m.id}
                  onClick={() => {
                    // Set active
                    document.querySelectorAll('[data-sim-mod]').forEach(el => el.classList.remove('bg-blue-500/10','border-l-blue-500','text-blue-400'));
                    document.querySelector(`[data-sim-mod="${m.id}"]`)?.classList.add('bg-blue-500/10','border-l-blue-500','text-blue-400');
                    // Show module info
                    const info = document.getElementById('sim-info');
                    if (info) info.innerHTML = `<h2 class="text-lg font-bold mb-1">${m.id}. ${m.name}</h2><div class="text-xs text-slate-400 mb-2">Source: <span class="text-cyan-400">${m.file}</span> · ${m.tests} tests</div><div class="text-xs text-slate-500 mb-1"><b class="text-violet-400">Functions:</b> ${m.funcs}</div><div class="text-xs text-slate-500 mb-3"><b class="text-violet-400">Pester:</b> ${m.pester}</div><button onclick="document.getElementById('sim-term').innerHTML=document.getElementById('sim-data-${m.id}').textContent;document.getElementById('sim-status').textContent='P:${m.tests} F:0 · Module ${m.id}';document.getElementById('sim-status').style.color='#22c55e'" class="bg-green-500 text-black px-4 py-1.5 rounded text-xs font-bold cursor-pointer hover:bg-green-400">▶ Simulate Run</button>`;
                    // Clear terminal
                    const term = document.getElementById('sim-term');
                    if (term) term.innerHTML = `<span style="color:#555">Click "Simulate Run" to see test output for Module ${m.id}</span>`;
                    const status = document.getElementById('sim-status');
                    if (status) { status.textContent = `Module ${m.id} selected`; status.style.color = '#64748b'; }
                  }}
                  data-sim-mod={m.id}
                  className={`w-full text-left px-3 py-2 text-xs text-slate-400 border-l-2 border-transparent hover:bg-white/[0.02] hover:text-slate-200 transition-colors ${m.id === 1 ? 'bg-blue-500/10 border-l-blue-500 text-blue-400' : ''}`}
                >
                  <span className="font-mono text-[10px] text-slate-600 mr-1">{String(m.id).padStart(2,'0')}</span>
                  {m.name.replace(/^\d+\s+/, '')}
                  <span className="float-right text-[9px] text-slate-600">{m.tests}</span>
                </button>
              ))}
            </div>
            <div className="px-3 py-2 border-t border-slate-800">
              <div className="flex justify-between text-[9px] text-slate-500 mb-1"><span>Simulation</span><span>9/9</span></div>
              <div className="h-1.5 bg-slate-700 rounded-full overflow-hidden"><div className="h-full bg-gradient-to-r from-green-500 to-blue-500 rounded-full" style={{width:'100%'}}></div></div>
            </div>
          </div>

          {/* Main area */}
          <div className="flex-1 flex flex-col gap-4 min-w-0">
            {/* Dashboard */}
            <div className="flex gap-2">
              <div className="flex-1 bg-[#0a0e17] border border-slate-700 rounded-lg p-3 text-center">
                <div className="text-xl font-bold text-green-400">106</div>
                <div className="text-[8px] uppercase text-slate-500">Passed</div>
              </div>
              <div className="flex-1 bg-[#0a0e17] border border-slate-700 rounded-lg p-3 text-center">
                <div className="text-xl font-bold text-red-400">0</div>
                <div className="text-[8px] uppercase text-slate-500">Failed</div>
              </div>
              <div className="flex-1 bg-[#0a0e17] border border-slate-700 rounded-lg p-3 text-center">
                <div className="text-xl font-bold text-blue-400">107</div>
                <div className="text-[8px] uppercase text-slate-500">Total</div>
              </div>
              <div className="flex-1 bg-[#0a0e17] border border-slate-700 rounded-lg p-3 text-center">
                <div className="text-xl font-bold text-violet-400">85.8%</div>
                <div className="text-[8px] uppercase text-slate-500">Coverage</div>
                <div className="mt-1 h-1 bg-slate-700 rounded-full overflow-hidden"><div className="h-full bg-violet-500 rounded-full" style={{width:'85.8%'}}></div></div>
              </div>
            </div>

            {/* Split: info + terminal */}
            <div className="flex gap-4 flex-1 min-h-0">
              {/* Info panel */}
              <div className="flex-1 overflow-y-auto p-4 border border-slate-700 rounded-xl bg-[#0a0e17]" id="sim-info">
                <h2 className="text-lg font-bold mb-1">1. 01 Knowledge Refresh</h2>
                <div className="text-xs text-slate-400 mb-2">Source: <span className="text-cyan-400">Azure-Cloud-Analyzer.ps1</span> · 5 tests</div>
                <div className="text-xs text-slate-500 mb-1"><b className="text-violet-400">Functions:</b> Get-AzureResourceInsights</div>
                <div className="text-xs text-slate-500 mb-3"><b className="text-violet-400">Pester:</b> Mock, Should -Be, Should -Invoke</div>
                <button
                  onClick={() => {
                    const term = document.getElementById('sim-term');
                    if (term) term.innerHTML = (simOutput[1] || '').split('\n').map(l => {
                      if (l.includes('[+]')) return `<span style="color:#4ade80">${l.replace(/</g,'&lt;')}</span>`;
                      if (l.includes('[.]')) return `<span style="color:#555;font-style:italic">${l.replace(/</g,'&lt;')}</span>`;
                      if (l.includes('[-]')) return `<span style="color:#f87171">${l.replace(/</g,'&lt;')}</span>`;
                      if (l.startsWith('Tests ') || l.startsWith('Coverage')) return `<span style="color:#4ade80">${l.replace(/</g,'&lt;')}</span>`;
                      if (l.includes('Describing') || l.includes('Context')) return `<span style="color:#22d3ee">${l.replace(/</g,'&lt;')}</span>`;
                      if (l.includes('→')) return `<span style="color:#555">${l.replace(/</g,'&lt;')}</span>`;
                      return `<span style="color:#555">${l.replace(/</g,'&lt;')}</span>`;
                    }).join('\n');
                    const status = document.getElementById('sim-status');
                    if (status) { status.textContent = 'P:5 F:0 · Module 1'; status.style.color = '#22c55e'; }
                  }}
                  className="bg-green-500 text-black px-4 py-1.5 rounded text-xs font-bold cursor-pointer hover:bg-green-400"
                >▶ Simulate Run</button>
              </div>

              {/* Terminal */}
              <div className="w-1/2 flex flex-col border border-slate-700 rounded-xl overflow-hidden bg-black min-w-0">
                <div className="h-8 bg-[#1a1a1a] flex items-center px-3 gap-1.5 border-b border-[#333] shrink-0">
                  <span className="w-2.5 h-2.5 rounded-full bg-[#ff5f57]"></span>
                  <span className="w-2.5 h-2.5 rounded-full bg-[#febc2e]"></span>
                  <span className="w-2.5 h-2.5 rounded-full bg-[#28c840]"></span>
                  <span className="text-[9px] text-[#666] ml-2 font-mono">PowerShell — Pester v5.7.1 (Simulation)</span>
                </div>
                <pre
                  id="sim-term"
                  className="flex-1 overflow-y-auto p-3 font-mono text-xs leading-relaxed text-[#ccc] whitespace-pre-wrap"
                  style={{fontSize:'11px',lineHeight:'1.5'}}
                >
                  <span style={{color:'#555'}}>Welcome to Pester Lab Simulation.{'\n'}Select a module then click Simulate Run.{'\n\n'}NOTE: This is a read-only simulation.{'\n'}To run real tests, use the terminal:{'\n\n'}  cd Pester-Delivery/Day-1/Pester-Lab-Day1{'\n'}  .\Start-Lab.ps1 -Web</span>
                </pre>
                <div className="h-7 bg-[#060a12] border-t border-[#333] flex items-center px-3 text-[10px] shrink-0">
                  <span id="sim-status" className="text-slate-500">Ready (simulation mode)</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Hidden data elements for each module's output */}
        {Object.entries(simOutput).map(([id, output]) => (
          <script key={id} id={`sim-data-${id}`} type="text/plain" dangerouslySetInnerHTML={{__html: output.split('\n').map(l => {
            const e = l.replace(/</g,'&lt;').replace(/>/g,'&gt;');
            if (l.includes('[+]')) return `<span style="color:#4ade80">${e}</span>`;
            if (l.includes('[.]')) return `<span style="color:#555;font-style:italic">${e}</span>`;
            if (l.includes('[-]')) return `<span style="color:#f87171">${e}</span>`;
            if (l.startsWith('Tests ') || l.startsWith('Coverage')) return `<span style="color:#4ade80">${e}</span>`;
            if (l.includes('Describing') || l.includes('Context')) return `<span style="color:#22d3ee">${e}</span>`;
            if (l.includes('→') || l.includes('──')) return `<span style="color:#555">${e}</span>`;
            return `<span style="color:#888">${e}</span>`;
          }).join('\n')}} />
        ))}
      </div>
      <Footer />
    </>
  );
}
