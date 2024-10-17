# Define the drive you want to check, usually the system drive (C:)
$drive = "C:"

# Get the BitLocker status of the drive
$bitlockerStatus = Get-BitLockerVolume -MountPoint $drive

# Check if BitLocker is enabled or disabled
if ($bitlockerStatus.ProtectionStatus -eq 'On') {
    Write-Host "BitLocker is ON. Turning it off..."

    # Disable BitLocker
    Disable-BitLocker -MountPoint $drive

    # Wait for the decryption process to complete
    $decryptionStatus = Get-BitLockerVolume -MountPoint $drive
    while ($decryptionStatus.VolumeStatus -ne 'FullyDecrypted') {
        Write-Host "Decryption in progress..."
        Start-Sleep -Seconds 30
        $decryptionStatus = Get-BitLockerVolume -MountPoint $drive
    }
    Write-Host "BitLocker decryption completed."

    # Re-enable BitLocker after turning it off
    Write-Host "Turning BitLocker back on..."
    Enable-BitLocker -MountPoint $drive -RecoveryPasswordProtector

    # Wait for the encryption process to complete
    $encryptionStatus = Get-BitLockerVolume -MountPoint $drive
    while ($encryptionStatus.VolumeStatus -ne 'FullyEncrypted') {
        Write-Host "Encryption in progress..."
        Start-Sleep -Seconds 30
        $encryptionStatus = Get-BitLockerVolume -MountPoint $drive
    }
    Write-Host "BitLocker encryption completed."

} else {
    Write-Host "BitLocker is OFF. Turning it on..."

    # Enable BitLocker if it is not already enabled
    Enable-BitLocker -MountPoint $drive -RecoveryPasswordProtector

    # Wait for the encryption process to complete
    $encryptionStatus = Get-BitLockerVolume -MountPoint $drive
    while ($encryptionStatus.VolumeStatus -ne 'FullyEncrypted') {
        Write-Host "Encryption in progress..."
        Start-Sleep -Seconds 30
        $encryptionStatus = Get-BitLockerVolume -MountPoint $drive
    }
    Write-Host "BitLocker encryption completed."
}
