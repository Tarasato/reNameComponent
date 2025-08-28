# =============================
# Run as Administrator
# =============================

# CPU Name
$ProcessorNameString = "AMD Ryzen 9 9900X3D 16-Core Processor"

# FriendlyName for Display Adapter
$friendlyName = "NVIDIA GeForce RTX 5090"

# Driver key of Display Adapter
$driverKey = "{4d36e968-e325-11ce-bfc1-08002be10318}\0000"

# ProcessorNameString
$cpuPath = "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0"

try {
    Set-ItemProperty -Path $cpuPath -Name "ProcessorNameString" -Value $ProcessorNameString -Force
    Write-Output "Successfully changed ProcessorNameString to: $ProcessorNameString"
} catch {
    Write-Output "Failed to update ProcessorNameString: $_"
}

# Find Driver key in HKLM:\SYSTEM\CurrentControlSet\Enum\PCI
$enumPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI"

# Write-Output "`n=== Checking for Device with Driver = $driverKey ==="

Get-ChildItem -Path $enumPath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $props = Get-ItemProperty -Path $_.PSPath -ErrorAction Stop

        if ($props.Driver -eq $driverKey) {
            # Write-Output "Found Device: $($_.PSPath)"

            # Check FriendlyName at device level
            $friendly = Get-ItemProperty -Path $_.PSPath -Name "FriendlyName" -ErrorAction SilentlyContinue

            if (-not $friendly) {
                # If no FriendlyName → create one
                New-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $friendlyName -PropertyType String -Force | Out-Null
                # Write-Output "Created FriendlyName with value '$friendlyName Successfully'"
            } else {
                # If FriendlyName exists → update it
                Set-ItemProperty -Path $_.PSPath -Name "FriendlyName" -Value $friendlyName -Force
                Write-Output "Updated FriendlyName to '$friendlyName Successfully'"
            }
        }
    } catch {}
}

Write-Host "Press any key to exit..."
$x = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")