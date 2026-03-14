class Node
{
    [int]$X
    [int]$Y
    [Node]$Next

    Node([int]$x, [int]$y, [Node]$next)
    {
        $this.X = $x
        $this.Y = $y
        $this.Next = $next
    }
}