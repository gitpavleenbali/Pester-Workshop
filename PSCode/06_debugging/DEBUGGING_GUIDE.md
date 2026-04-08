# PowerShell Debugging Guide
# How to use 'Start Debugging' with Variables, Watch, Call Stack, and Breakpoints

## Method 1: Using Visual Studio Code (Recommended)

### Step 1: Open the script in VS Code
1. Open VS Code
2. Open the file: `06_debugging\Debug-Demo.ps1`
3. Install the PowerShell extension if not already installed

### Step 2: Set Breakpoints
1. Click in the left margin (line numbers area) to set breakpoints at these strategic lines:
   - Line 20: `$validationResult = Test-InputValidation -Data $InputData -Level $ProcessingLevel`
   - Line 30: `$processedChunk = Process-DataChunk -ChunkData $chunk -Level $ProcessingLevel`
   - Line 47: `$result = [PSCustomObject]@{`
   - Line 134: `$result = Get-ProcessedData -InputData $sampleData -ProcessingLevel 2 -EnableLogging`

### Step 3: Start Debugging
1. Press F5 or go to Run > Start Debugging
2. Or press Ctrl+Shift+P, type "PowerShell: Start Debugging" and select it

### Step 4: Use Debug Features
When breakpoint hits:

**Variables Panel (Left side):**
- View Local variables: $InputData, $ProcessingLevel, $startTime, etc.
- View Global variables: $PSVersionTable, $env:USERNAME, etc.
- Expand objects to see properties

**Watch Panel:**
- Add expressions to watch:
  - `$processedItems.Count`
  - `$InputData.Length`
  - `$validationResult.IsValid`
  - `$duration.TotalMilliseconds`

**Call Stack Panel:**
- Shows current function hierarchy
- Click on stack frames to navigate up/down the call chain

**Debug Actions:**
- Continue (F5): Run to next breakpoint
- Step Over (F10): Execute current line
- Step Into (F11): Enter function calls
- Step Out (Shift+F11): Exit current function

## Method 2: Using PowerShell ISE

### Step 1: Open PowerShell ISE
1. Run `powershell_ise` or open PowerShell ISE
2. Open the Debug-Demo.ps1 file

### Step 2: Set Breakpoints
1. Right-click on line numbers and select "Toggle Breakpoint"
2. Or press F9 on the desired line

### Step 3: Start Debugging
1. Press F5 to run the script
2. When breakpoint hits, use Debug menu options

### Step 4: Debug Features in ISE
- **Variables**: Check the Variables pane at the bottom
- **Call Stack**: View in the Debug menu > Call Stack
- **Breakpoints**: Manage in Debug menu > List Breakpoints

## Method 3: Using PowerShell Console Commands

### Set Breakpoints Manually:
```powershell
# Set line breakpoint
Set-PSBreakpoint -Script ".\06_debugging\Debug-Demo.ps1" -Line 20

# Set command breakpoint
Set-PSBreakpoint -Command "Get-ProcessedData"

# Set variable breakpoint
Set-PSBreakpoint -Variable "result" -Mode Write

# List all breakpoints
Get-PSBreakpoint

# Run the script - it will hit breakpoints
.\06_debugging\Debug-Demo.ps1
```

### Debug Commands When Breakpoint Hits:
```powershell
# Step commands
s          # Step Into
v          # Step Over
o          # Step Out
c          # Continue

# Information commands
k          # Get call stack (Get-PSCallStack)
l          # List source around current line

# Variable inspection
$var       # Check any variable value
Get-Variable -Scope Local
Get-Variable -Scope Script

# Exit debugger
q          # Quit debugging
```

## Quick Debug Setup Commands:

Run these commands in PowerShell to quickly set up debugging:

```powershell
# Navigate to the script directory
cd "PSCode\06_debugging"

# Set breakpoints for the demo
Set-PSBreakpoint -Script ".\Debug-Demo.ps1" -Line 20  # Main function start
Set-PSBreakpoint -Script ".\Debug-Demo.ps1" -Line 30  # Processing loop
Set-PSBreakpoint -Script ".\Debug-Demo.ps1" -Line 134 # Result creation

# Run the script with debugging
.\Debug-Demo.ps1
```

## What to Watch For During Debugging:

### Variables to Inspect:
- `$InputData` - Original input string
- `$processedItems` - Array of processed chunks
- `$errorCount` - Number of errors encountered
- `$validationResult` - Validation results object
- `$chunk` - Current data chunk being processed
- `$result` - Final result object

### Watch Expressions to Add:
- `$processedItems.Count` - Number of items processed
- `$InputData.Length` - Length of input data
- `$duration.TotalMilliseconds` - Processing duration
- `$validationResult.IsValid` - Validation status

### Call Stack to Observe:
When breakpoint hits, you'll see:
1. Start-DebuggingDemo (main function)
2. Get-ProcessedData (processing function)
3. Test-InputValidation or Process-DataChunk (nested functions)

## Tips for Effective Debugging:

1. **Set Strategic Breakpoints**: At function entry points, loops, and decision points
2. **Use Conditional Breakpoints**: Right-click breakpoint to add conditions
3. **Inspect Object Properties**: Expand objects in Variables panel
4. **Use Immediate Window**: Type expressions to evaluate during debugging
5. **Step Through Carefully**: Use Step Into for detailed flow, Step Over for high-level flow