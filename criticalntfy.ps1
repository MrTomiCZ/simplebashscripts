# Put this in the startup dir along with critical.bat except disable criticalntfy.ps1 (this) in the task manager

# Install-Module BurntToast -Scope CurrentUser # toast other
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$hwnd = [Win32]::GetConsoleWindow()

if ($hwnd -ne [IntPtr]::Zero) {
    [Win32]::ShowWindow($hwnd, 0) | Out-Null
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Net.Http
$URL = (Get-Content "$env:USERPROFILE/.att.url" -Raw).Trim()
$TOKEN = (Get-Content "$env:USERPROFILE/.att.token" -Raw).Trim()

$client = New-Object System.Net.Http.HttpClient
$client.DefaultRequestHeaders.Add("Authorization", "Bearer "+$TOKEN)

$response = $client.GetAsync(
    "$URL/json",
    [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
).Result

$stream = $response.Content.ReadAsStreamAsync().Result
$reader = New-Object System.IO.StreamReader($stream)

while ($null -ne ($line = $reader.ReadLine())) {
    $event = $line | ConvertFrom-Json

    $title = $event.title
    if (-not $title) { $title = "" }
    $msge = $event.message
    if (-not $msge) { $msge = "att<blank>" }

    if ($event.event -eq "message") {
        [System.Windows.Forms.MessageBox]::Show(
            $msge,
            $title,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}
