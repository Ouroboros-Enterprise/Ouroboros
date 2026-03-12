namespace Ouroboros.Include;

using System.Security.Cryptography;

public static class RNGMachine
{
    public static int GetRandomInt(int minInclusive, int maxInclusive)
    {
        return RandomNumberGenerator.GetInt32(minInclusive, maxInclusive + 1);
    }

    public static (int X, int Y) GetRandomCoordinates(int maxX, int maxY)
    {
        int x = GetRandomInt(0, maxX);
        int y = GetRandomInt(0, maxY);
        return (x, y);
    }
}
