using module .\Game.psm1
using module .\Terminal.psm1
using module .\Input.psm1

if ($PSVersionTable.PSVersion.Major -ge 5)
{
    [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
}

Clear-Host

$playAgain = $true

while ($playAgain) {
    [int]$startX = [int](Get-Random -Minimum 0 -Maximum 20)
    [int]$startY = [int](Get-Random -Minimum 0 -Maximum 20)

    try
    {
        $game = [Game]::new($startX, $startY)
    }
    catch
    {
        Write-Host "Runtime error during game init at line $($_.InvocationInfo.ScriptLineNumber):" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        break
    }

    [Terminal]::ClearDisplay()

    Write-Host "--- OUROBOROS PowerShell ---"
    Write-Host "Press SPACE to start or 'Q' to Quit..."

    for (;;)
    {
        [int]$inputKey = [int]([Input]::GetKeyPress())

        if ($inputKey -eq 32 -or $inputKey -eq 13)
        {
            break
        }

        if ($inputKey -eq 81 -or $inputKey -eq 113 -or $inputKey -eq 27)
        {
            $playAgain = $false
            break
        }

        Start-Sleep -Milliseconds 10
    }

    if (-not $playAgain)
    {
        break
    }

    try
    {
        $game.Start()
    }
    catch
    {
        Write-Host "Runtime error during game loop at line $($_.InvocationInfo.ScriptLineNumber):" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        break
    }

    Write-Host "`n`nPress 'R' to Retry or 'Q' to Quit..."

    for (;;)
    {
        [int]$inputKey = [int]([Input]::GetKeyPress())

        if ($inputKey -eq 82 -or $inputKey -eq 114)
        {
            $playAgain = $true
            break
        }

        if ($inputKey -eq 81 -or $inputKey -eq 113 -or $inputKey -eq 27)
        {
            $playAgain = $false
            break
        }

        Start-Sleep -Milliseconds 10
    }
}

[Terminal]::HideCursor()
Write-Host "`nThanks for playing!"

for ($i = 5; $i -ge 0; --$i)
{
    Write-Host -NoNewline "`r`e[2KClosing in $i seconds..."
    Start-Sleep -Seconds 1
}
[Terminal]::ShowCursor()

Write-Host
