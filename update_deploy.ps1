# update_deploy.ps1
$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

function Exists($cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

Write-Host "Checking environment..."
if (-not (Exists "git")) { throw "Git not found. Please install Git and add to PATH." }
if (-not (Exists "npm")) { throw "npm not found. Please install Node.js (includes npm)." }

# ensure npm global path added
try {
    $prefix = (npm config get prefix) 2>$null
    if ($prefix -and (Test-Path $prefix) -and ($env:Path -notlike "*$prefix*")) {
        $env:Path += ";" + $prefix
    }
} catch {}

# check git repo
try {
    git rev-parse --is-inside-work-tree | Out-Null
} catch {
    throw "Current directory is not a git repository."
}

$branch = ""
try {
    $branch = (git rev-parse --abbrev-ref HEAD).Trim()
} catch {
    $branch = "main"
}

$remote = (git remote) | Where-Object { $_ -ne "" } | Select-Object -First 1
if (-not $remote) {
    throw "No remote found. Run: git remote add origin https://github.com/<yourname>/watch-docs.git"
}

Write-Host "Building docs manifest..."
npm run build | Write-Host

$changes = (git status --porcelain)
if (-not $changes) {
    Write-Host "No changes detected."
    exit 0
}

git add -A
$dt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$filesChanged = ($changes | Measure-Object -Line).Lines
$commitMsg = "chore: docs update ($dt, $filesChanged files)"
git commit -m $commitMsg | Write-Host

Write-Host "Pushing to $remote/$branch ..."
git push $remote $branch | Write-Host

Write-Host "Done. Vercel will auto-build and deploy."
