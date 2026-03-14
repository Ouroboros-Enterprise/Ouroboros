using module .\Node.psm1
using module .\Snake.psm1

class Apple
{
    [int]$X
    [int]$Y

    Apple([Snake]$snake)
    {
        $this.Eat($snake)
    }

    [void] Eat([Snake]$snake)
    {
        for ($i = 0; $i -lt 1000; ++$i)
        {
            $blocked = $false

            $rx = Get-Random -Minimum 0 -Maximum 20
            $ry = Get-Random -Minimum 0 -Maximum 20

            $curr = $snake.Head

            while ($null -ne $curr)
            {
                if ($curr.X -eq $rx -and $curr.Y -eq $ry)
                {
                    $blocked = $true
                    break
                }
                $curr = $curr.Next
            }

            if (-not $blocked)
            {
                $this.X = $rx
                $this.Y = $ry
                break
            }
        }
    }
}