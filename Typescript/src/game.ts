import Apple from "./apple.js";
import GUI from "./gui.js";
import { Input } from "./input.js";
import Node from "./node.js";
import { sleep_ms } from "./sleep.js";
import Snake from "./snake.js";
import { hideCursor, showCursor } from "./terminal.js";

export default class Game {
    private score: number;
    private snake: Snake;
    private apple: Apple;
    private gui: GUI;

    constructor(start_x: number, start_y: number) {
        this.score = 0;
        this.snake = new Snake(
            start_x,
            start_y,
            new Node(start_x, start_y + 1, null),
        );
        this.apple = new Apple(this.snake);
        this.gui = new GUI();
    }

    public async start() {
        hideCursor();

        let dx = 1;
        let dy = 0;
        let running = true;

        const inputListener = async () => {
            while (running) {
                const keyInfo = await Input.waitForKey();
                const key = keyInfo.name;

                switch (key) {
                    case "w":
                    case "W":
                    case "up":
                        if (dy !== 1) {
                            dx = 0;
                            dy = -1;
                        }
                        break;

                    case "s":
                    case "S":
                    case "down":
                        if (dy !== -1) {
                            dx = 0;
                            dy = 1;
                        }
                        break;

                    case "a":
                    case "A":
                    case "left":
                        if (dx !== 1) {
                            dx = -1;
                            dy = 0;
                        }
                        break;

                    case "d":
                    case "D":
                    case "right":
                        if (dx !== -1) {
                            dx = 1;
                            dy = 0;
                        }
                        break;

                    case "q":
                    case "Q":
                    case "escape":
                        running = false;
                        break;
                }
            }
        };

        inputListener();

        while (running) {
            let ax = this.snake.head.x + dx;
            let ay = this.snake.head.y + dy;

            let grow = ax === this.apple.x && ay === this.apple.y;

            if (grow) {
                this.apple.eat(this.snake);
                ++this.score;
            }

            if (!this.snake.move(ax, ay, grow)) {
                break;
            }

            this.gui.genGUI(this.snake, this.apple, this.score);

            await sleep_ms(300);
        }

        GUI.gameOver();
        showCursor();
        await Input.waitForExit();
    }
}
