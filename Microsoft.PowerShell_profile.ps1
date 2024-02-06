New-Alias -Name nano -Value Notepad
New-Alias -Name Tada -Value Write-Host Tada it works the way you want!
Set-Alias -Name cat -Value bat -Option AllScope

$ohMyPoshInstalled = Get-Command oh-my-posh -ErrorAction SilentlyContinue

$PowerShellProfileLocation = "$env:USERPROFILE\.powershellprofile\Microsoft.PowerShell_profile.ps1"

if (-not $ohMyPoshInstalled) {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "First time this Profile is ran it needs to be ran as admin"
        Exit
    }
    
    winget install --id=7zip.7zip -e
    winget install JanDeDobbeleer.OhMyPosh -s winget
    oh-my-posh font install FiraCode

    $settingsPath = "$env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $jsonContent = Get-Content -Path $settingsPath | ConvertFrom-Json

    $jsonContent.profiles.defaults.font.Face = 'FiraCode Nerd Font'

    $jsonContent | ConvertTo-Json | Set-Content -Path $settingsPath

    Write-Host "Oh-My-Posh is initialized with the provided configuration, and Windows Terminal font is set to FiraCode Nerd Font. There might be some issues with the font so go and check that it's set correctly"


    
}
else {
    oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/M365Princess.omp.json' | Invoke-Expression
}

function ifconfig ($name) { 
    if ($null -eq $name) {
                
        Get-NetIPAddress | Select-Object InterfaceAlias, IPAddressFamily | Sort-Object InterfaceAlias, IPAddressFamily -Unique
    }
    else {
        Get-NetIPAddress -InterfaceAlias $name #| Select-Object InterfaceAlias, IPAddressFamily, IPAddressess
    }
}
    
function touch {
    param (
        [string]$FileName
    )
    if (-not (Test-Path $FileName)) {
        New-Item -ItemType File -Name $FileName | Out-Null
    }
    else {
            (Get-Item $FileName).LastWriteTime = Get-Date
    }
}

function Edit-Profile {
    # Check if Visual Studio Code is installed
    $vscodeInstalled = $null -ne (Get-Command "code" -ErrorAction SilentlyContinue)
    
    if ($vscodeInstalled) {
        # If Visual Studio Code is installed, use it to edit the profile
        code $PROFILE
    }
    else {
        # If Visual Studio Code is not installed, use Notepad
        notepad $PROFILE
    }
}

function Start-WebServer {
    param (
        [int]$port = 8080
    )
    python -m http.server $port
}

function New-Venv {
    param (
        [string]$envName = '.'
    )
    python -m venv $envName
    Write-Host "Virtual environment '$envName' created."
}

function Get-PublicIPAddress {
    $ipInfo = Invoke-RestMethod -Uri "http://ipinfo.io/json"
    $ipInfo.ip
}

function Download-File {
    param (
        [string]$url,
        [string]$destination
    )
    Invoke-WebRequest -Uri $url -OutFile $destination
}

function Test-CompilerInstalled {
    $compilerPath = Get-Command gcc -ErrorAction SilentlyContinue
    if ($compilerPath) {
        Write-Host "C compiler found: $($compilerPath.Source)" -ForegroundColor Green
    }
    else {
        Write-Host "C compiler not found. Please install a C compiler." -ForegroundColor Red
    }
}



function knock {
    Start-Job -ScriptBlock {Test-NetConnection -ComputerName "128.39.198.13" -Port 631 -InformationLevel Quiet} | Wait-Job -Timeout 1
    Start-Job -ScriptBlock {Test-NetConnection -ComputerName "128.39.198.13" -Port 123 -InformationLevel Quiet} | Wait-Job -Timeout 1
    Start-Job -ScriptBlock {Test-NetConnection -ComputerName "128.39.198.13" -Port 80 -InformationLevel Quiet} | Wait-Job -Timeout 1
    Start-Job -ScriptBlock {Test-NetConnection -ComputerName "128.39.198.13" -Port 443 -InformationLevel Quiet} | Wait-Job -Timeout 1
    code --remote ssh-remote+"dhcp.ssn"
}

function Go-Desktop {
    Set-Location $([System.IO.Path]::Combine([System.Environment]::GetFolderPath('Desktop')))
}

function Go-Downloads {
    Set-Location $([System.IO.Path]::Combine([System.Environment]::GetFolderPath('Downloads')))
}

function Get-IpGeolocation {
    param (
        [string]$IpAddress
    )

    $geoInfo = Invoke-RestMethod -Uri "https://ipinfo.io/$IpAddress/json"
    Write-Host "Geolocation for IP ${IpAddress}:"
    Write-Host "Country: $($geoInfo.country)"
    Write-Host "City: $($geoInfo.city)"
    Write-Host "Region: $($geoInfo.region)"
}

function Test-PortOpen {
    param (
        [string]$computer,
        [int]$port
    )

    Test-NetConnection -ComputerName $computer -Port $port
}

function Get-SystemInformation {
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $cpuInfo = Get-CimInstance Win32_Processor
    $memoryInfo = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum

    Write-Host "System Information:"
    Write-Host "OS: $($osInfo.Caption) $($osInfo.Version)"
    Write-Host "Processor: $($cpuInfo.Name)"
    Write-Host "Memory: $($memoryInfo.Sum / 1GB) GB"
}

function Show-WiFiPasswords {
    $wifiProfiles = (netsh wlan show profiles) -match "All User Profile" | ForEach-Object { $_ -replace "^\s+|\s+$" }
    
    foreach ($profile in $wifiProfiles) {
        $password = (netsh wlan show profile name="$profile" key=clear) -match "Key Content" | ForEach-Object { $_ -replace "^\s+|\s+$" }
        Write-Host "${profile}: $password"
    }
}

function mac-lookup{
    param (
        [string]$macAddress
    )

    if ($macAddress -eq "") {
        Write-Host -ForegroundColor Red "No Mac Address was entered"
        return
    }

    $response = Invoke-RestMethod -Uri "https://api.maclookup.app/v2/macs/$($macAddress)"


    if (-not $response.found) {
        Write-Host -ForegroundColor Red "No vendor found"
        return
    }

    Write-Host $response.company
}

function useless-fact() {
    param (
        [string]$Daily
    )

    if (-not $Daily -eq "" -or $Daily -eq "-d") {
        (Invoke-RestMethod -Uri "https://uselessfacts.jsph.pl/api/v2/facts/today").text
    } else {
        (Invoke-RestMethod -Uri "https://uselessfacts.jsph.pl/api/v2/facts/random").text

    }
}


function Profile-Sync {
    # Define profile paths
    $PowerShellProfileLocation = "$env:USERPROFILE\.powershellprofile"
    $LocalProfile = Join-Path -Path $PowerShellProfileLocation -ChildPath "profile.ps1"

    # Check if the local profile directory exists, if not, create it
    if (-not (Test-Path -Path $PowerShellProfileLocation -PathType Container)) {
        New-Item -Path $PowerShellProfileLocation -ItemType Directory -Force
    }

    # Copy the current profile to the local profile directory
    Copy-Item -Path $PROFILE -Destination $LocalProfile -Force

    # Change directory to the profile location
    Set-Location $PowerShellProfileLocation

    # Check if there are any changes to the local profile file
    $hasChanges = git diff-index --quiet HEAD -- $LocalProfile

    if ($hasChanges -eq $false) {
        # Commit changes if there are any
        git add $LocalProfile
        git commit -m "Profile sync"
    }

    # Pull changes from the remote repository
    git pull
}



function Profile-Help {
    param (
        [switch]$Detailed
    )

    Write-Host "Profile functions:"
        # Display only command names without detailed explanations
        Get-Command -Name ifconfig, touch, Edit-Profile, Start-WebServer, New-Venv, Get-PublicIPAddress, Download-File, Go-Downloads, Go-Desktop, Profile-Help |
        ForEach-Object { Write-Host "`n$($_.Name)" -ForegroundColor Green }
}


