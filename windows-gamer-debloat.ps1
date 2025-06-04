
# windows-gamer-debloat.ps1
# Created by Jay Nicholson (Ghotet) | github.com/Ghotet
# Gamer-focused debloat script with Xbox Safe and Full Purge modes
# License: CC-BY-NC-SA 4.0

# === Admin Check ===
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator."
    exit
}

# === Restore Point ===
Write-Host "Creating restore point..." -ForegroundColor Cyan
Checkpoint-Computer -Description "windows-gamer-debloat" -RestorePointType "MODIFY_SETTINGS"
Write-Host "Restore point created." -ForegroundColor Green

# === Mode Selection ===
Write-Host "`nSelect Mode:" -ForegroundColor Yellow
Write-Host "[1] Xbox Safe - Keeps Game Bar and Xbox features"
Write-Host "[2] F**k Xbox - Removes all Xbox/Game Bar services"
$mode = Read-Host "Enter choice (1 or 2)"

# === Universal Debloat (applies to both) ===
Write-Host "Applying core debloat (both modes)..." -ForegroundColor Yellow

# Services
Stop-Service "SysMain" -Force
Set-Service "SysMain" -StartupType Disabled
Stop-Service "DiagTrack" -Force
Set-Service "DiagTrack" -StartupType Disabled

# Registry Tweaks
Set-ItemProperty -Path "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38
New-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -PropertyType DWord -Force

# Remove Bloat Apps (safe)
Get-AppxPackage *Clipchamp* | Remove-AppxPackage
Get-AppxPackage *3DViewer* | Remove-AppxPackage
Get-AppxPackage *bingweather* | Remove-AppxPackage
Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage
Get-AppxPackage *ZuneMusic* | Remove-AppxPackage
Get-AppxPackage *ZuneVideo* | Remove-AppxPackage
Get-AppxPackage *Microsoft.GetHelp* | Remove-AppxPackage
Get-AppxPackage *Microsoft.Getstarted* | Remove-AppxPackage
Get-AppxPackage *People* | Remove-AppxPackage

# Optional Removal Based on Mode
if ($mode -eq "2") {
    Write-Host "Purging Xbox/GameBar/Cortana components..." -ForegroundColor Red

    # Xbox + Game Bar
    Get-AppxPackage *xbox* | Remove-AppxPackage
    Get-AppxPackage *gamebar* | Remove-AppxPackage
    Get-AppxPackage *Microsoft.XboxGamingOverlay* | Remove-AppxPackage

    # Cortana
    Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage

    # Feedback Hub
    Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage
}

Write-Host "`nDebloat complete. Please reboot your system." -ForegroundColor Green
