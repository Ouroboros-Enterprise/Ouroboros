import getRandomInt from "./random.js";
import type Snake from "./snake.js";

export default class Apple {
    public x: number = 0;
    public y: number = 0;

    constructor(snake: Snake) {
        this.eat(snake);
    }

    public eat(snake: Snake) {
        for (let i = 0; i < 1000; ++i) {
            let blocked = false;

            const rx = getRandomInt(0, 19);
            const ry = getRandomInt(0, 19);

            for (const node of snake.head) {
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
