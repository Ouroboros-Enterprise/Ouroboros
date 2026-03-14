using module .\Node.psm1
using module .\Snake.psm1
using module .\Apple.psm1
using module .\Terminal.psm1
using module .\Input.psm1
using module .\GUI.psm1

class Game
{
    [int]$Score
    [Snake]$Snake
    [Apple]$Apple
    [GUI]$GUI

    Game([int]$sx, [int]$sy)
    {
        $this.Score = 0
        $this.Snake = [Snake]::new($sx, $sy, [Node]::new($sx, $sy + 1, $null))
        $this.Apple = [Apple]::new($this.Snake)
        $this.GUI = [GUI]::new()
    }

    [void] Start()
    {
        [Terminal]::HideCursor()

        [int]$dx = 1
        [int]$dy = 0
        [bool]$running = $true

        for (;;)
        {
            [int]$inputKey = [int]([Input]::GetKeyPress())

            switch ($inputKey)
            {
                # Up keys (W and up-key)
                { $_ -eq 87 -or $_ -eq 38 -or $_ -eq 72 }
                {
                    if ($dy -ne 1)
                    {
                        $dx = 0
                        $dy = -1
                    }
                    continue
                }

                # Down keys (S and down-key)
                { $_ -eq 83 -or $_ -eq 40 -or $_ -eq 80 }
                {
                    if ($dy -ne -1)
                    {
                        $dx = 0
                        $dy = 1
                    }
                    continue
                }

                # Left keys (A and left-key)
                { $_ -eq 65 -or $_ -eq 37 -or $_ -eq 75 }
                {
                    if ($dx -ne 1)
                    {
                        $dx = -1
                        $dy = 0
                    }
                    continue
                }

                # Right keys (D and right-key)
                { $_ -eq 68 -or $_ -eq 39 -or $_ -eq 77 }
                {
                    if ($dx -ne -1)
                    {
                        $dx = 1
                        $dy = 0
                    }
                    continue
                }

                # Quit the game (Q and esc)
                { $_ -eq 81 -or $_ -eq 113 -or $_ -eq 27 }
                {
                    $running = $false
                    continue
                }
            }

            if (-not $running)
            {
                break
            }

            [int]$ax = [int]$this.Snake.Head.X + $dx
            [int]$ay = [int]$this.Snake.Head.Y + $dy

            $grow = $ax -eq $this.Apple.X -and $ay -eq $this.Apple.Y

            if ($grow)
            {
                $this.Apple.Eat($this.Snake)
                ++$this.Score
            }

            if (-not $this.Snake.Move($ax, $ay, $grow))
            {
                break
            }

            $this.GUI.GenGui($this.Snake, $this.Apple, $this.Score)

            Start-Sleep -Milliseconds 300
        }

        [GUI]::GameOver()
        [Terminal]::ShowCursor()
        [Input]::WaitForExit()
    }
}