class Input
{
    static [int] GetKeyPress()
    {
        if ([System.Console]::KeyAvailable)
        {
            $keyInfo = [System.Console]::ReadKey($true)
            return [int]$keyInfo.Key
        }
        return -1
    }

    static [void] WaitForExit()
    {
        Write-Host "`nPress a key to exit..." -ForegroundColor Gray

        while ([System.Console]::KeyAvailable)
        {
            [System.Console]::ReadKey($true)
        }
        [System.Console]::ReadKey($true) | Out-Null
    }
}