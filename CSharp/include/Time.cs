namespace Ouroboros.Include;

public static class Time
{
    public static void SleepMs(int milliseconds)
    {
        Thread.Sleep(milliseconds);
    }

    public static void SleepS(int seconds)
    {
        Thread.Sleep(seconds * 1000);
    }
}