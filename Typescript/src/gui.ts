import type Apple from "./apple.js";
import type Snake from "./snake.js";
import { gotoXY } from "./terminal.js";

export default class GUI {
    private map: string[][];

    constructor() {
        this.map = Array.from({ length: 22 }, () => Array(22).fill(" "));
    }

    public genGUI(snake: Snake, apple: Apple, score: number) {
        gotoXY(1, 1);

        this.map = Array.from({ length: 22 }, () => Array(22).fill(" "));

        this.placeBorders();
        this.placeSnake(snake);
        this.placeApple(apple);

        let out: string = "";

        for (let j = 0; j < 22; ++j) {
            for (let i = 0; i < 22; ++i) {
                let field = this.map[i]![j]!;

                if (field === "#") {
                    out += "##";
                } else {
                    out += field + " ";
                }
            }

            if (j === 0) {
                out += `   Score:  ${score}`;
            }

            out += "\n";
        }

        process.stdout.write(out);
    }

    public static gameOver() {
        gotoXY(1, 23);

        console.log("         ___                 ");
        console.log("        / __|__ _ _ __  ___  ");
        console.log("       | (_ / _` | ''  \\/ -_) ");
        console.log("        \\___\\__,_|_|_|_\\___| ");
        console.log("         ___                 ");
        console.log("        / _ \\_ _____ _ _     ");
        console.log("       | (_) \\ V / -_) ''_|   ");
        console.log("        \\___/ \\_/\\___|_|     ");
    }

    private placeBorders() {
        for (let i = 0; i < 22; ++i) {
            this.map[0]![i] = "#";
            this.map[21]![i] = "#";
            this.map[i]![0] = "#";
            this.map[i]![21] = "#";
        }
    }

    private placeSnake(snake: Snake) {
        for (const node of snake.head) {
            if (node == snake.head) {
                this.map[node.x + 1]![node.y + 1] = "X";
            } else {
                this.map[node.x + 1]![node.y + 1] = "O";
            }
        }
    }

    private placeApple(apple: Apple) {
        this.map[apple.x + 1]![apple.y + 1] = "@";
    }
}
