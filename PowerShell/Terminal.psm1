class Terminal
{
    hidden static [string]$Esc = [char]27

    static [void] GotoXY([int]$x, [int]$y)
    {
        Write-Host -NoNewline "$([Terminal]::Esc)[$($y);$($x)H"
    }

    static [void] HideCursor()
    {
        Write-Host -NoNewline "$([Terminal]::Esc)[?25l"
    }

    static [void] ShowCursor()
    {
        Write-Host -NoNewline "$([Terminal]::Esc)[?25h"
    }

    static [void] ClearDisplay()
    {
        Write-Host -NoNewline "$([Terminal]::Esc)[2J$([Terminal]::Esc)[H"
    }
}