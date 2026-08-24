:: Put this in the startup dir along with criticalntfy.ps1 except disable criticalntfy.ps1 in the task manager
:: i have an "alias" for pwsh.bat in %systemroot% and the contents are: @powershell.exe %*
start conhost %systemroot%\pwsh.bat -Command ".\criticalntfy.ps1"
