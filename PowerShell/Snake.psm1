using module .\Node.psm1

class Snake
{
    [Node]$Head

    Snake([int]$x, [int]$y, [Node]$next)
    {
        $this.Head = [Node]::new($x, $y, $next)
    }

    hidden [bool] WallCollision()
    {
        $x = $this.Head.X
        $y = $this.Head.Y
        return $x -lt 0 -or $x -ge 20 -or $y -lt 0 -or $y -ge 20
    }

    hidden [bool] SelfCollision()
    {
        $x = $this.Head.X
        $y = $this.Head.Y
        $curr = $this.Head.Next

        while ($null -ne $curr)
        {
            if ($curr.X -eq $x -and $curr.Y -eq $y)
            {
                return $true;
            }
            $curr = $curr.Next
        }
        return $false;
    }

    [bool] Move([int]$nx, [int]$ny, [bool]$grow)
    {
        $oldHead = [Node]::new($this.Head.X, $this.Head.Y, $this.Head.Next)

        $this.Head.Next = $oldHead

        $this.Head.X = $nx
        $this.Head.Y = $ny

        if (-not $grow -and $null -ne $this.Head.Next)
        {
            if ($null -eq $this.Head.Next.Next)
            {
                $this.Head.Next = $null
            }
            else
            {
                $curr = $this.Head.Next

                while ($null -ne $curr.Next -and $null -ne $curr.Next.Next)
                {
                    $curr = $curr.Next
                }
                $curr.Next = $null
            }
        }
        return -not $this.WallCollision() -and -not $this.SelfCollision()
    }
}