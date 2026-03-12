namespace Ouroboros.Include;

public class Apple
{
    public int X { get; private set; }

    public int Y { get; private set; }

    public Apple(Snake snake)
    {
        Eat(snake);
    }

    public void Eat(Snake snake)
    {
        for (int i = 0; i < 1000; ++i)
        {
            var pos = RNGMachine.GetRandomCoordinates(19, 19);

            if (!snake.GetNodes().Any(node => (node.X, node.Y) == pos))
            {
                (X, Y) = pos;
                return;
            }
        }
    }
}
