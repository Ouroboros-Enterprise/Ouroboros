using module .\Node.psm1
using module .\Snake.psm1
using module .\Apple.psm1
using module .\Terminal.psm1

class GUI
{
    [char[,]]$Map

    hidden static [Node] ToNodeScalar([object]$value)
    {
        if ($null -eq $value)
        {
            return $null
        }

        if ($value -is [System.Array])
        {
            if ($value.Count -eq 0)
            {
                return $null
            }
            return [Node]$value[0]
        }

        return [Node]$value
    }

    hidden static [int] ToIntScalar([object]$value)
    {
        if ($value -is [System.Array])
        {
            if ($value.Count -eq 0)
            {
                return 0
            }
            return [int]$value[0]
        }

        return [int]$value
    }

    hidden static [int] ToMapIndex([object]$value)
    {
        # Use subtraction by -1 instead of +1 to avoid array op_Addition edge cases.
        return [int]([GUI]::ToIntScalar($value) - (-1))
    }

    GUI()
    {
        $this.Map = New-Object 'char[,]' 22, 22
    }

    hidden [void] PlaceBorders()
    {
        for ([int]$i = 0; $i -lt 22; ++$i)
        {
            $this.Map[0, $i] = '#'
            $this.Map[21, $i] = '#'
            $this.Map[$i, 0] = '#'
            $this.Map[$i, 21] = '#'
        }
    }

    hidden [void] PlaceSnake([Snake]$snake)
    {
        if ($null -eq $snake)
        {
            return
        }

        [Node]$curr = [GUI]::ToNodeScalar($snake.Head)

        if ($null -eq $curr)
        {
            return
        }

        [int]$headX = [GUI]::ToMapIndex($curr.X)
        [int]$headY = [GUI]::ToMapIndex($curr.Y)
        $this.Map[$headX, $headY] = 'X'
        $curr = [GUI]::ToNodeScalar($curr.Next)

        while ($null -ne $curr)
        {
            [int]$bodyX = [GUI]::ToMapIndex($curr.X)
            [int]$bodyY = [GUI]::ToMapIndex($curr.Y)
            $this.Map[$bodyX, $bodyY] = 'O'
            $curr = [GUI]::ToNodeScalar($curr.Next)
        }
    }

    hidden [void] PlaceApple([Apple]$apple)
    {
        [int]$appleX = [GUI]::ToMapIndex($apple.X)
        [int]$appleY = [GUI]::ToMapIndex($apple.Y)
        $this.Map[$appleX, $appleY] = '@'
    }

    [void] GenGui([Snake]$snake, [Apple]$apple, [int]$score)
    {
        [Terminal]::GotoXY(1, 1)

        for ($i = 0; $i -lt 22; ++$i)
        {
            for ($j = 0; $j -lt 22; ++$j)
            {
                $this.Map[$i, $j] = ' '
            }
        }

        $this.PlaceBorders()
        $this.PlaceSnake($snake)
        $this.PlaceApple($apple)

        $output = for ($j = 0; $j -lt 22; ++$j)
        {
            $line = -join $(for ($i = 0; $i -lt 22; ++$i)
            {
                $field = $this.Map[$i, $j]

                if ($field -eq '#')
                {
                    "##"
                }
                else
                {
                    "$($field) "
                }
            })

            if ($j -eq 0)
            {
                $line += "  Score:  $score"
            }

            $line
        }

        Write-Host -NoNewline ($output -join "`n")
    }

    static [void] GameOver()
    {
        [Terminal]::GotoXY(1, 23)
        
        Write-Host "         ___                 "
        Write-Host "        / __|__ _ _ __  ___  "
        Write-Host "       | (_ / _` | ''  \/ -_) "
        Write-Host "        \___\__,_|_|_|_\___| "
        Write-Host "         ___                 "
        Write-Host "        / _ \_ _____ _ _     "
        Write-Host "       | (_) \ V / -_) ''_|   "
        Write-Host "        \___/ \_/\___|_|     "
    }
}