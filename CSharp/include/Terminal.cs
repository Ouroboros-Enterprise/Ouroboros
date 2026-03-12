namespace Ouroboros.Include;

public static class Terminal
{
    public static void GotoXY(int x, int y) => Console.SetCursorPosition(x, y);

    public static void HideCursor() => Console.CursorVisible = false;

    public static void ShowCursor() => Console.CursorVisible = true;

    public static void ClearDisplay()
    {
        Console.Clear();
    }
}