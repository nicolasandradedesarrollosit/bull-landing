<#
.SYNOPSIS
  Builds and runs Bull from source: install, build, test, check the example app and start it.

.EXAMPLE
  ./scripts/setup.ps1 -Repo ..\bull
.EXAMPLE
  ./scripts/setup.ps1 -Repo https://github.com/<you>/bull.git -E2E -NoDev
#>
[CmdletBinding()]
param(
  # Local path to the Bull repository, or a git URL to clone (also read from $env:BULL_REPO).
  [string]$Repo = $env:BULL_REPO,
  # Where to clone a git URL.
  [string]$Dir = ".bull",
  # Also run the end-to-end tests of the CLI binary.
  [switch]$E2E,
  # Do not start the example app's dev server at the end.
  [switch]$NoDev,
  # Print the commands without running them.
  [switch]$DryRun,
  [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Usage {
  @"
Usage: scripts/setup.ps1 -Repo <path-or-git-url> [options]

Builds the Bull monorepo, runs its tests, checks the example app and starts it.

Options:
  -Repo <path|url>   Local path to the Bull repository, or a git URL to clone
                     (also read from the BULL_REPO environment variable)
  -Dir <path>        Where to clone a git URL (default: .bull)
  -E2E               Also run the end-to-end tests of the CLI binary
  -NoDev             Do not start the example app's dev server at the end
  -DryRun            Print the commands without running them
  -Help              Show this help
"@
}

function Step([string]$Text) { Write-Host ""; Write-Host "$([char]0x2649) $Text" -ForegroundColor Magenta }
function Fail([string]$Text) { Write-Host "x $Text" -ForegroundColor Red; exit 1 }

function Invoke-In([string]$Path, [string]$Command, [string[]]$Arguments = @()) {
  Write-Host "  `$ (cd $Path && $Command $($Arguments -join ' '))" -ForegroundColor DarkGray
  if ($DryRun) { return }
  Push-Location $Path
  try {
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { Fail "$Command $($Arguments -join ' ') failed with exit code $LASTEXITCODE." }
  } finally {
    Pop-Location
  }
}

if ($Help) { Show-Usage; exit 0 }
if (-not $Repo) { Show-Usage; Write-Host ""; Fail "Pass -Repo <path-or-git-url> (or set BULL_REPO)." }

Write-Host "Bull setup"

Step "Checking the toolchain"
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Fail "Node.js is not installed. Install Node.js 20 or newer." }
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { Fail "npm is not installed." }
$nodeMajor = [int](node -p "process.versions.node.split('.')[0]")
if ($nodeMajor -lt 20) { Fail "Node.js $(node -v) is too old. Bull needs Node.js 20 or newer." }
Write-Host "  ok node $(node -v), npm $(npm -v)"

Step "Locating the Bull repository"
if ($Repo -match '^(https?://|git@|ssh://)') {
  if (Test-Path (Join-Path $Dir ".git")) {
    Write-Host "  ok already cloned in $Dir"
  } else {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail "git is needed to clone $Repo." }
    Write-Host "  `$ git clone --depth 1 $Repo $Dir" -ForegroundColor DarkGray
    if (-not $DryRun) {
      git clone --depth 1 $Repo $Dir
      if ($LASTEXITCODE -ne 0) { Fail "git clone failed." }
    }
  }
  $Root = $Dir
} else {
  if (-not (Test-Path $Repo)) { Fail "$Repo does not exist." }
  $Root = $Repo
}
if (-not $DryRun -and -not (Test-Path (Join-Path $Root "packages/cli/package.json"))) {
  Fail "$Root does not look like the Bull repository (packages/cli is missing)."
}
Write-Host "  ok $Root"

Step "Installing dependencies"
if (Test-Path (Join-Path $Root "package-lock.json")) { Invoke-In $Root "npm" @("ci") } else { Invoke-In $Root "npm" @("install") }

Step "Building the packages"
Invoke-In $Root "npm" @("run", "build")

Step "Running the unit tests"
Invoke-In $Root "npm" @("test")

if ($E2E) {
  Step "Running the end-to-end tests"
  Invoke-In $Root "npx" @("vitest", "run", "-c", "vitest.e2e.config.ts")
}

Step "Checking the example app's architecture"
Invoke-In $Root "node" @("packages/cli/dist/bin.js", "check", "examples/todo-app")

if (-not $NoDev) {
  Step "Starting the example app (Ctrl+C to stop)"
  Invoke-In (Join-Path $Root "examples/todo-app") "npm" @("run", "dev")
} else {
  Write-Host ""
  Write-Host "Done. Start the example with: cd $Root/examples/todo-app; npm run dev" -ForegroundColor Green
}
