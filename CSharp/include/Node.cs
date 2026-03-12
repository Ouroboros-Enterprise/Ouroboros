namespace Ouroboros.Include;

public class Node
{
    public int X { get; set; }

    public int Y { get; set; }

    public Node? Next { get; set; }

    public Node(int x, int y, Node? next = null)
    {
        X = x;
        Y = y;
        Next = next;
    }

    public IEnumerable<Node> GetNodes()
    {
        Node? curr = this;

        while (curr != null)
        {
            yield return curr;
            curr = curr.Next;
        }
    }
}