namespace Ouroboros.Include;

public static class Input
{
    public static ConsoleKey WaitForKey()
    {
        return Console.ReadKey(intercept: true).Key;
    }

    public static ConsoleKey? GetKeyPress()
    {
        if (Console.KeyAvailable)
        {
            return Console.ReadKey(intercept: true).Key;
        }
        return null;
    }

    public static void WaitForExit()
    {
        Console.WriteLine("Press a key to exit...");
        Console.ReadKey(intercept: true);
    }
}