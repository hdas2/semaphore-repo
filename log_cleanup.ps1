$isAdmin = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

if (-not $isAdmin.IsInRole($adminRole)) {
    # If not running as admin, restart the script as admin
    $args = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $args" -Verb RunAs
    exit
}
# Define the paths to the directories containing log files
$logDirectories = @(
    "E:\Logs"
)

# Define the list of file types/extensions to be considered as log files
$fileTypes = @(
    "*.log",
    "*.txt",
    "*.php"
)

# Loop through each application log directory
foreach ($logDirectory in $logDirectories) {
    # Check if the directory exists
    if (Test-Path $logDirectory) {
        # Loop through each file type
        foreach ($fileType in $fileTypes) {
            # Get all files of the specified type in the directory and filter those older than 3 days
            $logFiles = Get-ChildItem -Path $logDirectory -Filter $fileType | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-0) }

            # Delete the old log files
            foreach ($file in $logFiles) {
                Remove-Item $file.FullName -Force
                Write-Host "Deleted:$($file.FullName)"
            } 
        }
    } else {
        Write-Host "Directory not found: $logDirectory"
    }
}
exit
