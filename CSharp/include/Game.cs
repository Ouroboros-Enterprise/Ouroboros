namespace Ouroboros.Include;

public class Game
{
    private int Score;

    private readonly Snake Snake;

    private readonly Apple Apple;

    private readonly GUI GUI;

    public Game(int start_x, int start_y)
    {
        Score = 0;
        Snake = new(start_x, start_y, new(start_x, start_y + 1));
        Apple = new(Snake);
        GUI = new();
    }

    public void Start()
    {
        Terminal.HideCursor();

        int dx = 1;
        int dy = 0;
        int ax, ay;

        for (;;)
        {
            var input = Input.GetKeyPress() ?? ConsoleKey.NoName;

            (dx, dy) = input switch
            {
                ConsoleKey.W or ConsoleKey.UpArrow when dy != 1 => (0, -1),

                ConsoleKey.S or ConsoleKey.DownArrow when dy != -1 => (0, 1),

                ConsoleKey.A or ConsoleKey.LeftArrow when dx != 1 => (-1, 0),

                ConsoleKey.D or ConsoleKey.RightArrow when dx != -1 => (1, 0),

                _ => (dx, dy)
            };

            if (input is ConsoleKey.Q or ConsoleKey.Escape)
            {
                break;
            }

            (ax, ay) = (Snake.Head.X + dx, Snake.Head.Y + dy);

            var grow = (ax == Apple.X && ay == Apple.Y);

            if (grow)
            {
                Apple.Eat(Snake);
                ++Score;
            }

            if (!Snake.Move(ax, ay, grow))
            {
                break;
            }

            GUI.GenGUI(Snake, Apple, Score);
            Time.SleepMs(300);
        }
        GUI.GameOver();
        Terminal.ShowCursor();
        Input.WaitForExit();
    }
}