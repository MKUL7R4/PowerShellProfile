function prompt 
{
    $Time = (Get-Date).ToString("hh:mm") 
    $host.ui.rawui.WindowTitle = (Get-Location)
    "$Time > "
}

function Write-Animation {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [Alias("Msg", "Message")]
        [string]$Object,

        # Modes
        [switch]$Vertical,
        [switch]$Rainbow,
        [switch]$Gradient,
        [switch]$MultiGradient,
        [switch]$Wave,
        [switch]$Pulse,
        [switch]$Glitch,
        [switch]$Neon,

        # Timing
        [int]$Time = 0,

        # Colors
        [string[]]$GradientStops = @("#FF0000", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#FF00FF"),
        [string]$StartColor = "#FF0000",
        [string]$EndColor = "#FFFF00",
        
        # Preset Modes
        [ValidateSet( "Fire", "Ice", "Synthwave", "Matrix", "Neon", "Rainbow", "Cyberpunk", "Cosmic", "Gold", "Sunrise", "Ocean", "Forest", "Toxic", "Glacier", "Volcano", "Galaxy", "Pastel", "Inferno", "Biohazard", "Unicorn" )] [string]$Mode,

        # Background (ANSI)
        [string]$BGColor = "Black",

        #NoNewLine
        [switch]$NoNewLine
    )

    begin {
        $Length = $Object.Length
        $Delay = if ($Time) { $Time / $Length } else { 25 }

        # Convert hex → RGB
        function Convert-HexToRgb {
            param([string]$Hex)
            $Hex = $Hex.TrimStart('#')
            [PSCustomObject]@{
                R = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
                G = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
                B = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
            }
        }

        # ANSI 24-bit color
        function New-AnsiColor {
            param([int]$R, [int]$G, [int]$B)
            "`e[38;2;${R};${G};${B}m"
        }

        # Multi-stop gradient generator
        function Get-MultiGradient {
            param([string[]]$Stops, [int]$Steps)

            $RGBStops = $Stops | ForEach-Object { Convert-HexToRgb $_ }
            $Segments = $RGBStops.Count - 1
            $Colors = @()

            for ($s = 0; $s -lt $Segments; $s++) {
                $Start = $RGBStops[$s]
                $End = $RGBStops[$s + 1]

                for ($i = 0; $i -lt ($Steps / $Segments); $i++) {
                    $t = $i / (($Steps / $Segments) - 1)

                    [int]$R = $Start.R + ($End.R - $Start.R) * $t
                    [int]$G = $Start.G + ($End.G - $Start.G) * $t
                    [int]$B = $Start.B + ($End.B - $Start.B) * $t

                    $Colors += New-AnsiColor -R $R -G $G -B $B
                }
            }

            return $Colors[0..($Steps - 1)]
        }

        # --- MODE PRESETS ---------------------------------------------------------
        $ModePresets = @{
            Fire      = @("#FF0000", "#FF5A00", "#FF9A00", "#FFFF00")
            Ice       = @("#0033FF", "#00AFFF", "#66FFFF", "#FFFFFF")
            Synthwave = @("#8B00FF", "#FF00AA", "#FF5500", "#FFCC00")
            Matrix    = @("#003300", "#00AA00", "#00FF00", "#AAFFAA")
            Neon      = @("#00FFFF", "#00AFFF", "#0088FF", "#00FFFF")
            Rainbow   = @("#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#00FFFF", "#0000FF", "#8B00FF")
            Cyberpunk = @("#FF00FF", "#9900FF", "#3300FF", "#0099FF")
            Cosmic    = @("#0000AA", "#3300CC", "#6600FF", "#9900FF")
            Gold      = @("#FFD700", "#FFEA70", "#FFF8DC")
            Sunrise   = @("#FF4500", "#FF8C00", "#FFD700", "#FFFFE0")
            Ocean     = @("#001F3F", "#0074D9", "#7FDBFF", "#39CCCC")
            Forest    = @("#013220", "#145A32", "#1E8449", "#52BE80")
            Toxic     = @("#00FF00", "#88FF00", "#CCFF00", "#FFFF00")
            Glacier   = @("#004466", "#007799", "#00AACC", "#66DDEE")
            Volcano   = @("#330000", "#660000", "#CC3300", "#FF6600")
            Galaxy    = @("#110022", "#330044", "#550077", "#8800AA", "#BB33CC")
            Pastel    = @("#FFB3BA", "#FFDFBA", "#FFFFBA", "#BAFFC9", "#BAE1FF")
            Inferno   = @("#FF0000", "#FF2200", "#FF4400", "#FF8800", "#FFBB00")
            Biohazard = @("#00FF88", "#00CC66", "#009944", "#006622")
            Unicorn   = @("#FF99FF", "#CC99FF", "#9999FF", "#99CCFF", "#99FFFF")
        }

        # If Mode is used, override GradientStops and enable MultiGradient
        if ($Mode -and $ModePresets.ContainsKey($Mode)) {
            $GradientStops = $ModePresets[$Mode]
            $MultiGradient = $true
        }

        # Single gradient
        if ($Gradient) {
            $StartRGB = Convert-HexToRgb $StartColor
            $EndRGB = Convert-HexToRgb $EndColor

            $GradientColors = for ($i = 0; $i -lt $Length; $i++) {
                $t = $i / ($Length - 1)
                [int]$R = $StartRGB.R + ($EndRGB.R - $StartRGB.R) * $t
                [int]$G = $StartRGB.G + ($EndRGB.G - $StartRGB.G) * $t
                [int]$B = $StartRGB.B + ($EndRGB.B - $StartRGB.B) * $t
                New-AnsiColor -R $R -G $G -B $B
            }
        }

        # Multi-stop gradient
        if ($MultiGradient) {
            $GradientColors = Get-MultiGradient -Stops $GradientStops -Steps $Length
        }

        # Rainbow fallback
        $RainbowColors = @(
            "#FF0000", "#FF7F00", "#FFFF00", "#00FF00",
            "#00FFFF", "#0000FF", "#8B00FF"
        ) | ForEach-Object { Convert-HexToRgb $_ }

        $RainbowIndex = 0

        # Background ANSI
        $BGAnsi = ""
        if ($BGColor -ne "Black") {
            $BGAnsi = "`e[48;2;0;0;0m"
        }

        # Glitch characters
        $GlitchChars = @("▒", "▓", "░", "█", "/", "\", ":", ";", "*", "+", "=")
    }

    process {
        for ($i = 0; $i -lt $Length; $i++) {

            $char = $Object[$i]

            # Glitch mode
            if ($Glitch -and (Get-Random -Min 0 -Max 10) -eq 0) {
                $char = $GlitchChars | Get-Random
            }

            # Neon flicker
            if ($Neon -and (Get-Random -Min 0 -Max 8) -eq 0) {
                $char = "`e[38;2;255;255;255m$char`e[0m"
            }

            # Determine color
            $FG = switch ($true) {

                $MultiGradient { $GradientColors[$i]; break }
                $Gradient { $GradientColors[$i]; break }

                $Rainbow {
                    $rgb = $RainbowColors[$RainbowIndex]
                    $RainbowIndex = ($RainbowIndex + 1) % $RainbowColors.Count
                    New-AnsiColor -R $rgb.R -G $rgb.G -B $rgb.B
                    break
                }

                $Wave {
                    $t = (Math::Sin($i / 2) + 1) / 2
                    [int]$R = 0 + (255 * $t)
                    [int]$G = 0
                    [int]$B = 255 - (255 * $t)
                    New-AnsiColor -R $R -G $G -B $B
                    break
                }

                $Pulse {
                    $t = (Math::Sin($i / 3) + 1) / 2
                    [int]$R = 255 * $t
                    [int]$G = 255 * $t
                    [int]$B = 255 * $t
                    New-AnsiColor -R $R -G $G -B $B
                    break
                }

                default { "" }
            }

            # Output
            if ($Vertical) {
                Write-Host "$FG$char`e[0m"
            }
            else {
                Write-Host -NoNewLine "$FG$char`e[0m"
            }

            Start-Sleep -Milliseconds $Delay
        }

        if (-not $Vertical -and -not $NoNewLine) { Write-Host }
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


$Runes = @(
    "ᚠ", "ᚡ", "ᚢ", "ᚣ", "ᚤ", "ᚥ", "ᚦ", "ᚧ", "ᚨ", "ᚩ", "ᚪ", "ᚫ", "ᚬ", "ᚭ", "ᚮ", "ᚯ",
    "ᚰ", "ᚱ", "ᚲ", "ᚳ", "ᚴ", "ᚵ", "ᚶ", "ᚷ", "ᚸ", "ᚹ", "ᚺ", "ᚻ", "ᚼ", "ᚽ", "ᚾ", "ᚿ",
    "ᛀ", "ᛁ", "ᛂ", "ᛃ", "ᛄ", "ᛅ", "ᛆ", "ᛇ", "ᛈ", "ᛉ", "ᛊ", "ᛋ", "ᛌ", "ᛍ", "ᛎ", "ᛏ",
    "ᛐ", "ᛑ", "ᛒ", "ᛓ", "ᛔ", "ᛕ", "ᛖ", "ᛗ", "ᛘ", "ᛙ", "ᛚ", "ᛛ", "ᛜ", "ᛝ", "ᛞ", "ᛟ"
)

Write-Host ""
Write-Host "  _/\_  " -ForegroundColor Magenta -BackgroundColor Black
Write-Animation ' (n^.^)D--* $' -Gradient -StartColor "#FF00FF" -EndColor "#FF00FF" -NoNewLine
$randomRuneArray = foreach ($i in 1..60) {
    $Runes | Get-Random
}
$runeString = $randomRuneArray -join ""
Write-Animation -Object "$runeString" -Mode Fire -NoNewLine
Write-Host ""
Write-Animation "~~ ᛞᛊᚳᛈᛟᛖᛊ ᚾᛟ ᚹᛟᛞᛊᚱ§ᚹᛊᚳᚳ ~~" -Mode Cosmic
Write-Animation "~~~ ᚹᚱᛟᚨᛐᚳᛊ ᛒᚴ ᛗᛕultra ~~~~" -Mode Cosmic

$Major = ($PSVersionTable).PSVersion.Major
$Minor = ($PSVersionTable).PSVersion.Minor
$Build = ($PSVersionTable).PSVersion.Patch
$FullPSVersion = "$Major"+"."+"$Minor"+"."+"$Build"

Write-Host "PowerShell Version: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
Write-Host "$FullPSVersion`n" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
$VerbosePreference = "SilentlyContinue"
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
<#
Write-Host "Installed Modules: " -NoNewLine -BackgroundColor Black -ForegroundColor Magenta
if ($Modules = Get-InstalledModule) {
    $moduleNames = $modules.Name
	Write-Host "$moduleNames" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
} else {
	Write-Host "None" -NoNewLine -BackgroundColor Black -ForegroundColor Yellow
}
#>
Write-Host ""
