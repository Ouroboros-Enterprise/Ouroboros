package com.ouroboros.include;

import java.util.Random;

public final class Apple {
    public int x, y;
    private final Random random = new Random();

    public Apple(Snake snake) {
        eat(snake);
    }

    public void eat(Snake snake) {
        for (int i = 0; i < 1000; ++i) {
            boolean blocked = false;
            int rx = random.nextInt(20);
            int ry = random.nextInt(20);

            for (Node node : snake.head) {
                if (node.x == rx && node.y == ry) {
                    blocked = true;
                    break;
                }
            }

            if (!blocked) {
                this.x = rx;
                this.y = ry;
                return;
            }
        }
    }
}
