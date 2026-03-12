using System.Runtime.InteropServices;

namespace Ouroboros.Include;

class GUI
{
    private readonly char[,] Map;

    public GUI()
    {
        Map = new char[22, 22];
        MemoryMarshal.CreateSpan(ref Map[0, 0], Map.Length).Fill(' ');
    }

    public void GenGUI(Snake snake, Apple apple, int score)
    {
        Terminal.GotoXY(1, 1);

        MemoryMarshal.CreateSpan(ref Map[0, 0], Map.Length).Fill(' ');

        PlaceBorders();
        PlaceSnake(snake);
        PlaceApple(apple);

        for (int j = 0; j < 22; ++j)
        {
            for (int i = 0; i < 22; ++i)
            {
                var field = Map[i, j];

                if (field == '#')
                {
                    Console.Out.Write("##");
                }
                else
                {
                    Console.Out.Write($"{field} ");
                }
            }

            if (j == 0)
            {
                Console.Out.Write($"  Score:  {score}");
            }

            Console.Out.WriteLine();
        }
    }

    public static void GameOver()
    {
        Terminal.GotoXY(1, 23);

        Console.Out.WriteLine("         ___                 ");
        Console.Out.WriteLine("        / __|__ _ _ __  ___  ");
        Console.Out.WriteLine("       | (_ / _` | ''  \\/ -_) ");
        Console.Out.WriteLine("        \\___\\__,_|_|_|_\\___| ");
        Console.Out.WriteLine("         ___                 ");
        Console.Out.WriteLine("        / _ \\_ _____ _ _     ");
        Console.Out.WriteLine("       | (_) \\ V / -_) ''_|   ");
        Console.Out.WriteLine("        \\___/ \\_/\\___|_|     ");
    }

    private void PlaceBorders()
    {
        int height = Map.GetLength(0);
        int width = Map.GetLength(1);

        MemoryMarshal.CreateSpan(ref Map[0, 0], width).Fill('#');

        MemoryMarshal.CreateSpan(ref Map[height - 1, 0], width).Fill('#');

        for (int i = 0; i < height; ++i)
        {
            Map[i, 0] = '#';
            Map[i, width - 1] = '#';
        }
    }

    private void PlaceSnake(Snake snake)
    {
        bool first = true;
        foreach (var node in snake.GetNodes())
        {
            if (first)
            {
                Map[node.X + 1, node.Y + 1] = 'X';
                first = false;
            }
            else
            {
                Map[node.X + 1, node.Y + 1] = 'O';
            }
        }
    }

    private void PlaceApple(Apple apple)
    {
        Map[apple.X + 1, apple.Y + 1] = '@';
    }
}