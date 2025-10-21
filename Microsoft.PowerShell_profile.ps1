function prompt 
{
$Time = (Get-Date).ToString("hh:mm") 
$host.ui.rawui.WindowTitle = (Get-Location)
"$Time > "
}

Function Write-Animation {
<#
.SYNOPSIS
    Animates a Write-Host output, with options to write vertically, change the write speed (time), and make text rainbow colored.
.NOTES
    Name: Write-Animation
    Author: Matt Karwoski
    Version: 1.0
    DateCreated: 8-21-25
.DESCRIPTION
    Parameters:
    Object - the message to animate
    FGColor - foreground color
    BGColor - background color
    Vertical - writes text vertically instead of horizontally
    Rainbow - writes foregroundcolor in rainbow colors
    Time - total time (ms) it takes for the whole string to print
.EXAMPLE
    Write-Animation "THE SKY IS FALLING!" -Vertical -Time 3000
    Write-Animation "My favorite track in Mario Kart is Rainbow Road!!!" -Rainbow -Time 250
    Write-Animation "Wake up, Neo..." -FGColor Green -BGColor Black -Time 2500
    Write-Animation -Msg "Add some flair to your scripting experience :)" -FGColor Magenta -BGColor White -Time 250
    Write-Animation -Msg "This is a prime example of everything that you can possibly do with this function." -Vertical -Rainbow -Time 12500
#>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias("Msg", "Message")][string]$Object,
        [ValidateScript( {[enum]::GetNames([consolecolor])} )][string]$FGColor = "White",
        [ValidateScript( {[enum]::GetNames([consolecolor])} )][string]$BGColor = "Black",
        [switch]$Vertical,
        [switch]$Rainbow,
        [int]$Time
    )
    BEGIN {
        $Char = 0
        $Length = $Object.Length
        if ($Time) {
            $TimeIncrement = $Time / $Length
        }
        $RainbowColors = @(
            'Red'
            'Yellow'
            'Green'
            'Cyan'
            'Blue'
            'Magenta'
        )
    }
    PROCESS {
        if ($Vertical -and !$Time -and !$Rainbow) {
            do {
                $DisplayChar = $Object[$Char]
                Write-Host "$DisplayChar" -ForegroundColor $FGColor -BackgroundColor $BGColor
                Start-Sleep -Milliseconds 25
                $Char++
            } until ($Char -eq $Length)
        } elseif ($Vertical -and $Time -and !$Rainbow) {
            do {
                $DisplayChar = $Object[$Char]
                Write-Host "$DisplayChar" -ForegroundColor $FGColor -BackgroundColor $BGColor
                Start-Sleep -Milliseconds $TimeIncrement
                $Char++
            } until ($Char -eq $Length)
        } elseif ($Vertical -and $Time -and $Rainbow) {
            $RainbowColorsInt = 0
            [int]$RainbowColorsCount = $RainbowColors.count
            do {
                if ($RainbowColorsInt -eq $RainbowColorsCount) {
                    $RainbowColorsInt = 0
                }
                $DisplayChar = $Object[$Char]
                Write-Host "$DisplayChar" -ForegroundColor $RainbowColors[$RainbowColorsInt] -BackgroundColor $BGColor
                Start-Sleep -Milliseconds $TimeIncrement
                $Char++
                $RainbowColorsInt++
            } until ($Char -eq $Length)
        } elseif ($Time -and !$Vertical -and !$Rainbow) {
            do {
                $DisplayChar = $Object[$Char]
                Write-Host -NoNewLine "$DisplayChar" -ForegroundColor $FGColor -BackgroundColor $BGColor
                Start-Sleep -Milliseconds $TimeIncrement
                $Char++
            } until ($Char -eq $Length)
        } elseif ($Time -and $Rainbow -and !$Vertical) {
            $RainbowColorsInt = 0
            [int]$RainbowColorsCount = $RainbowColors.count
            do {
                if ($RainbowColorsInt -eq $RainbowColorsCount) {
                    $RainbowColorsInt = 0
                }
                $DisplayChar = $Object[$Char]
                Write-Host -NoNewLine "$DisplayChar" -ForegroundColor $RainbowColors[$RainbowColorsInt] -BackgroundColor $BGColor
                Start-Sleep -Milliseconds $TimeIncrement
                $Char++
                $RainbowColorsInt++
            } until ($Char -eq $Length)
        } elseif ($Rainbow -and !$Time -and !$Vertical) {
            $RainbowColorsInt = 0
            [int]$RainbowColorsCount = $RainbowColors.count
            do {
                if ($RainbowColorsInt -eq $RainbowColorsCount) {
                    $RainbowColorsInt = 0
                }
                $DisplayChar = $Object[$Char]
                Write-Host -NoNewLine "$DisplayChar" -ForegroundColor $RainbowColors[$RainbowColorsInt] -BackgroundColor $BGColor
                Start-Sleep -Milliseconds 25
                $Char++
                $RainbowColorsInt++
            } until ($Char -eq $Length)
        } elseif ($Rainbow -and $Vertical -and !$Time) {
            $RainbowColorsInt = 0
            [int]$RainbowColorsCount = $RainbowColors.count
            do {
                if ($RainbowColorsInt -eq $RainbowColorsCount) {
                    $RainbowColorsInt = 0
                }
                $DisplayChar = $Object[$Char]
                Write-Host "$DisplayChar" -ForegroundColor $RainbowColors[$RainbowColorsInt] -BackgroundColor $BGColor
                Start-Sleep -Milliseconds 25
                $Char++
                $RainbowColorsInt++
            } until ($Char -eq $Length)
        } else {
            do {
                $DisplayChar = $Object[$Char]
                Write-Host -NoNewLine "$DisplayChar" -ForegroundColor $FGColor -BackgroundColor $BGColor
                Start-Sleep -Milliseconds 25
                $Char++
            } until ($Char -eq $Length)
        }
    }
    END {
        # This is the end, my friend.
    }
}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression

$White = @{ForegroundColor = "White"; BackgroundColor = "Black"}
$Cyan = @{ForegroundColor = "Cyan"; BackgroundColor = "Black"}
$Green = @{ForegroundColor = "Green"; BackgroundColor = "Black"}
$Yellow = @{ForegroundColor = "Yellow"; BackgroundColor = "Black"}
$Red = @{ForegroundColor = "Red"; BackgroundColor = "Black"}
$Blue = @{ForegroundColor = "Blue"; BackgroundColor = "Black"}
$Magenta = @{ForegroundColor = "Magenta"; BackgroundColor = "Black"}
$PurpSkurp = @{ForegroundColor = "White"; BackgroundColor = "DarkMagenta"}
$MattyIce = @{ForegroundColor = "White"; BackgroundColor = "DarkCyan"}
$MTron = @{ForegroundColor = "Green"; BackgroundColor = "DarkRed"}
$Blackberry = @{ForegroundColor = "Black"; BackgroundColor = "Magenta"}
$Stealth = @{ForegroundColor = "Black"; BackgroundColor = "Black"}

$Witch = ' (n^.^)D--* $'
$WitchLength = $Witch.Length
$Char = 0
$AllColors = [enum]::GetNames([consolecolor])
Write-Host "  _/\_       " -ForegroundColor Yellow -BackgroundColor Magenta  # Witch hat was I wearing again?
do {
    do {
        $DisplayChar = $Witch[$Char]
        Write-Host -NoNewLine "$DisplayChar" -ForegroundColor Yellow -BackgroundColor Magenta
        Start-Sleep -Milliseconds 15
        $Char++
    } until ($Char -eq $WitchLength)
    $SpellLength = 35
    $SpellLengthMinusOne = ($SpellLength - 1)
    $SpellArray = foreach ($S in 1..$SpellLength) {
        [char](Get-Random -Minimum 0 -Maximum 9999)
    }
    $Int = 0 # Put more points in Int, ya donkey!
    do {
        $RandomSplat = @{ForegroundColor = ($AllColors | Get-Random); BackgroundColor = ($AllColors | Get-Random)}
        $DisplayChar = $SpellArray[$Int]
        Write-Host "$DisplayChar" -NoNewLine @RandomSplat
        Start-Sleep -Milliseconds 15
        $Int++
    } until ($Int -eq $SpellLengthMinusOne)
} until ($Char -eq $WitchLength)
Write-Host ""
Write-Animation "~~ Welcome to PowerSpell ~~" -FGColor Yellow -BGColor Magenta
Write-Host ""
Write-Animation "~~~ Profile by MKultra ~~~~" -FGColor Yellow -BGColor Magenta
Write-Host ""

$Major = ($PSVersionTable).PSVersion.Major
$Minor = ($PSVersionTable).PSVersion.Minor
$Build = ($PSVersionTable).PSVersion.Build
$Revision = ($PSVersionTable).PSVersion.Revision
$FullPSVersion = "$Major"+"."+"$Minor"+"."+"$Build"+"."+"$Revision"

Write-Host "PowerShell Version: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$FullPSVersion`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
$VerbosePreference = "Continue"
Write-Host "Verbose Preference: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$VerbosePreference`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
Write-Host "ErrorAction Preference: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$ErrorActionPreference`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
Write-Host "Warning Preference: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$WarningPreference`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
Write-Host "ErrorView Preference: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$ErrorView`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
Write-Host "Confirm Preference: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$ConfirmPreference`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
$ExecutionPolicy = Get-ExecutionPolicy
Write-Host "Execution Policy: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$ExecutionPolicy`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
Write-Host "Installed Modules: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Get-InstalledModule

powercfg -restoredefaultschemes