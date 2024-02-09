function Get-PlatformInfo {
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    
    switch ($arch) {
        "AMD64" { return "X64" }
        "IA64" { return "X64" }
        "ARM64" { return "X64" }
        "EM64T" { return "X64" }
        "x86" { return "X86" }
        default { throw "Unknown architecture: $arch. Please contact HR for additional support." }
    }
}

function Request-String($url) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Lethal Mod Installer PowerShell Script")
    return $webClient.DownloadString($url)
}

function Request-Stream($url) {
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Lethal Mod Installer PowerShell Script")
    return [System.IO.MemoryStream]::new($webClient.DownloadData($url))
}

function Expand-Stream($zipStream, $destination) {
    # Create a temporary file to save the stream content
    $tempFilePath = [System.IO.Path]::GetTempFileName()

    # replace the temporary file extension with .zip
    $tempFilePath = [System.IO.Path]::ChangeExtension($tempFilePath, "zip")

    # Save the stream content to the temporary file
    $zipStream.Seek(0, [System.IO.SeekOrigin]::Begin)
    $fileStream = [System.IO.File]::OpenWrite($tempFilePath)
    $zipStream.CopyTo($fileStream)
    $fileStream.Close()

    # extract the temporary file to the destination folder
    Expand-Archive -Path $tempFilePath -DestinationPath $destination -Force

    # Delete the temporary file
    Remove-Item -Path $tempFilePath -Force
}

function Install ($arguments) {
    $platform = Get-PlatformInfo
    Write-Host "Detected platform: $platform"

    $lethalCompanyPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1966720").InstallLocation
    if ($null -eq $lethalCompanyPath) {
        throw "Steam Lethal Company install not found"
    }

    $bepInExPath = Join-Path $lethalCompanyPath "BepInEx"

    Write-Host "Lethal Company path: $lethalCompanyPath"
    Write-Host ""
    
    Write-Host "Downloading and installing the new experience"
    $downloadUrl = "https://drive.google.com/uc?export=download&id=1EPaDkOeU7acQiKE46b2mH_Ike5YDtzbV"
    $downloadStream = Request-Stream $downloadUrl
    Expand-Stream $downloadStream $lethalCompanyPath
    Write-Host "Experience installed"
    Write-Host ""
}

try {
    Install $args
    Write-Host "Install successful"
} catch {
    Write-Host "Install failed: $_"
}

Read-Host “The game has successfully been patched! Press ENTER to exit...”