namespace Ouroboros.Include;

public class Snake
{
    public Node Head { get; private set; }

    public Snake(int x, int y, Node? next = null)
    {
        Head = new Node(x, y, next);
    }

    public bool Move(int x, int y, bool grow)
    {
        Node old_head = new(Head.X, Head.Y, Head.Next);
        Head.Next = old_head;

        Head.X = x;
        Head.Y = y;

        if (!grow && Head.Next != null)
        {
            if (Head.Next.Next == null)
            {
                Head.Next = null;
            }
            else
            {
                Node curr = Head.Next;

                while (curr.Next != null && curr.Next.Next != null)
                {
                    curr = curr.Next;
                }

                curr.Next = null;
            }
        }

        return !WallCollison() && !SelfCollision();
    }

    public IEnumerable<Node> GetNodes() => Head.GetNodes();

    private bool WallCollison()
    {
        var x = Head.X;
        var y = Head.Y;

        return x < 0 || x >= 20 || y < 0 || y >= 20;
    }

    private bool SelfCollision()
    {
        Node? curr = Head.Next;

        while (curr != null)
        {
            if (curr.X == Head.X && curr.Y == Head.Y)
            {
                return true;
            }
            curr = curr.Next;
        }
        return false;
    }
}