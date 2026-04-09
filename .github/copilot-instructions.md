# Pester Workshop — Copilot Instructions

## Knowledge Sources

Always consult these references when answering Pester / PowerShell testing questions:

| Source | URL |
|---|---|
| Pester Documentation | https://pester.dev/ |
| Pester GitHub Repository | https://github.com/pester/pester |
| PowerShell Tests (community) | https://github.com/PowerShell/PowerShell-Tests |
| Quick Start Guide | https://pester.dev/docs/quick-start |
| Installation Guide | https://pester.dev/docs/introduction/installation |
| Command Reference | https://pester.dev/docs/commands/Add-ShouldOperator |
| Mocking Guide | https://pester.dev/docs/usage/mocking |
| Code Coverage Guide | https://pester.dev/docs/usage/code-coverage |
| Assertions (Should) | https://pester.dev/docs/assertions/should-command |
| Contributor Guide | https://pester.dev/docs/contributing/introduction |

These are stored in `.internal/docs/knowledge.txt`.

## Pester Quick Reference

- **What is Pester?** The ubiquitous test and mock framework for PowerShell (v5.7.1 latest, 3.3k+ GitHub stars).
- **Compatibility:** Windows PowerShell 5.1 and PowerShell 7.2+. Runs on Windows, Linux, macOS.
- **Install/Update:** `Install-Module -Name Pester -Force`
- **Run tests:** `Invoke-Pester <path-to-tests>`

### Core Constructs

```powershell
Describe 'Group of tests' {
    Context 'Sub-group / scenario' {
        BeforeAll { <# setup #> }
        AfterAll  { <# teardown #> }
        It 'Single test case' {
            <actual> | Should -Be <expected>
        }
    }
}
```

### Key Features

1. **Test Runner** — discovers and runs `.Tests.ps1` files, outputs nUnit XML.
2. **Assertions** — `Should -Be`, `Should -BeExactly`, `Should -Exist`, `Should -Throw`, `Should -BeNullOrEmpty`, etc.
3. **Mocking** — `Mock -CommandName <Cmdlet> -MockWith { }` + `Should -Invoke` to verify calls.
4. **Code Coverage** — `Invoke-Pester -CodeCoverage <scripts>`, exports JaCoCo format.
5. **CI/CD Integration** — works with GitHub Actions, Azure DevOps, Jenkins, AppVeyor, TeamCity.

### Mocking Example

```powershell
Describe 'Remove-Cache' {
    It 'Removes cached results' {
        Mock -CommandName Remove-Item -MockWith {}
        Remove-Cache
        Should -Invoke -CommandName Remove-Item -Times 1 -Exactly
    }
}
```

### Data-Driven Tests (TestCases)

```powershell
It "Given -Name '<Filter>', returns '<Expected>'" -TestCases @(
    @{ Filter = 'Earth'; Expected = 'Earth' }
    @{ Filter = 'ne*';   Expected = 'Neptune' }
) {
    param ($Filter, $Expected)
    (Get-Planet -Name $Filter).Name | Should -Be $Expected
}
```

## Workshop Context

This workspace supports a **2-day Pester workshop** for BASF:

- **Day 1:** Fundamentals, test structure (Describe/Context/It/Should), mocking, hands-on unit testing labs.
- **Day 2:** Advanced patterns (code coverage, quality gates, idempotency testing, negative testing), CI/CD integration with GitHub Actions, using GitHub Copilot for test generation.

See `.internal/docs/agenda.txt` for the full schedule.

## Guidelines for Copilot

- When generating PowerShell tests, always use **Pester v5 syntax** (BeforeAll/AfterAll blocks, `Should -<Operator>` syntax).
- Prefer `Should -Be` over deprecated v4 pipe syntax.
- Always use `.Tests.ps1` file naming convention.
- When mocking Azure cmdlets (Get-Az*, Invoke-RestMethod, etc.), never call real cloud resources.
- Include `BeforeAll` blocks for function definitions or module imports.
- Use `-TestCases` for data-driven / parameterized tests.
- Reference the knowledge sources above when the user asks about Pester best practices or syntax.
