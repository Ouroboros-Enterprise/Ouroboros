using Ouroboros.Include;

bool playAgain = true;

var start = new HashSet<ConsoleKey> { ConsoleKey.Spacebar, ConsoleKey.Enter };
var quit = new HashSet<ConsoleKey> { ConsoleKey.Q, ConsoleKey.Escape };
var retry = new HashSet<ConsoleKey> { ConsoleKey.R };

while (playAgain)
{
    Terminal.ClearDisplay();

    Console.Out.WriteLine("--- OUROBOROS C# ---");
    Console.Out.WriteLine("Press SPACE to start or 'Q' to Quit...");

    for (;;)
    {
        var input = Input.GetKeyPress() ?? ConsoleKey.NoName;

        if (start.Contains(input))
        {
            break;
        }

        if (quit.Contains(input))
        {
            playAgain = false;
            break;
        }

        Time.SleepMs(10);
    }

    if (!playAgain)
    {
        break;
    }

    var (sx, sy) = RNGMachine.GetRandomCoordinates(19, 19);
    new Game(sx, sy).Start();

    Console.Out.WriteLine("\n\nPress 'R' to Retry or 'Q' to Quit...");

    for (;;)
    {
        var input = Input.GetKeyPress() ?? ConsoleKey.NoName;

        if (retry.Contains(input))
        {
            playAgain = true;
            break;
        }

        if (quit.Contains(input))
        {
            playAgain = false;
            break;
        }

        Time.SleepMs(10);
    }
}

Terminal.HideCursor();
Console.Out.WriteLine("\nThanks for playing!");

for (int i = 5; i >= 0; --i)
{
    Console.Out.Write($"\rClosing in {i} seconds...");
    Time.SleepS(1);
}
Terminal.ShowCursor();
