############################################################
# WhoLogin Pro v2
############################################################

# -------------------------------
# Detect where this script is
# -------------------------------
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

# -------------------------------
# Load configuration
# -------------------------------
. "$Root\Config.ps1"

# -------------------------------
# FFmpeg location
# -------------------------------
$FFmpeg = Join-Path $Root "ffmpeg\bin\ffmpeg.exe"

# -------------------------------
# Captures folder
# -------------------------------
$CapturesFolder = Join-Path $Root "Captures"

# -------------------------------
# Logs folder
# -------------------------------
$LogsFolder = Join-Path $Root "Logs"

# -------------------------------
# Create Incident ID
# -------------------------------
$IncidentID = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# -------------------------------
# Incident Folder
# -------------------------------
$IncidentFolder = Join-Path $CapturesFolder "Incident_$IncidentID"

New-Item -ItemType Directory -Force -Path $IncidentFolder | Out-Null

# -------------------------------
# Computer Information
# -------------------------------
$ComputerName = $env:COMPUTERNAME
$UserName = $env:USERNAME
$Date = Get-Date -Format "yyyy-MM-dd"
$Time = Get-Date -Format "HH:mm:ss"

Write-Host ""
Write-Host "==============================="
Write-Host " WhoLogin Pro Started"
Write-Host "==============================="
Write-Host ""

Write-Host "Root Folder:"
Write-Host $Root

Write-Host ""

Write-Host "Incident:"
Write-Host $IncidentID

Write-Host ""

Write-Host "Computer:"
Write-Host $ComputerName

Write-Host ""

Write-Host "User:"
Write-Host $UserName

Write-Host ""

Write-Host "FFmpeg:"
Write-Host $FFmpeg

Write-Host ""

Write-Host "Incident Folder:"
Write-Host $IncidentFolder

Write-Host ""
Write-Host "Capturing Photos..."
Write-Host ""

for ($i = 1; $i -le $PhotoCount; $i++)
{

    $Photo = Join-Path $IncidentFolder ("Photo{0}.jpg" -f $i)

    & $FFmpeg `
        -y `
        -f dshow `
        -i video="$VideoDevice" `
        -frames:v 1 `
        $Photo

    Write-Host "Saved Photo $i"

    Start-Sleep -Seconds $PhotoDelay
}

Write-Host ""

if ($CaptureVideo)
{
    Write-Host "Recording Webcam Video..."

    $Video = Join-Path $IncidentFolder "Webcam.mp4"

    & $FFmpeg `
        -y `
        -f dshow `
        -i video="$VideoDevice" `
        -t $VideoLength `
        -c:v libx264 `
        -pix_fmt yuv420p `
        $Video

    Write-Host "Saved Webcam.mp4"
}

Write-Host ""

if ($CaptureAudio)
{
    Write-Host "Recording Microphone..."

    $Audio = Join-Path $IncidentFolder "Audio.wav"

    & $FFmpeg `
        -y `
        -f dshow `
        -i audio="$AudioDevice" `
        -t $AudioLength `
        $Audio

    Write-Host "Saved Audio.wav"
}

Write-Host ""


if ($WriteIncidentLog)
{
    $IncidentLog = Join-Path $IncidentFolder "Incident.txt"

@"
==============================
WhoLogin Pro
==============================

Incident ID : $IncidentID

Date : $Date
Time : $Time

Computer : $ComputerName
User : $UserName

Captured :

✔ Photo1.jpg
✔ Photo2.jpg
✔ Photo3.jpg
✔ Webcam.mp4
✔ Audio.wav

Status :

Capture Completed Successfully

==============================
"@ | Set-Content $IncidentLog
}