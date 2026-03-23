import Game from "./game.js";
import { Input } from "./input.js";
import getRandomInt from "./random.js";
import { sleep_s } from "./sleep.js";
import { clearDisplay, hideCursor, showCursor } from "./terminal.js";

let playAgain = true;

const start = new Set(["space", "return", "enter"]);
const quit = new Set(["q", "Q", "escape"]);
const retry = new Set(["r", "R"]);

const waitForMenuInput = async (
    accept: Set<string>,
): Promise<"accept" | "quit"> => {
    while (true) {
        const keyInfo = await Input.waitForKey();
        const key = keyInfo.name;

        if (key !== undefined && accept.has(key)) {
            return "accept";
        }

        if (key !== undefined && quit.has(key)) {
            return "quit";
        }
    }
};

while (playAgain) {
    clearDisplay();

    console.log("--- OUROBOROS TypeScript ---");
    console.log("Press SPACE to start or 'Q' to Quit...");

    const startDecision = await waitForMenuInput(start);
    if (startDecision === "quit") {
        playAgain = false;
        break;
    }

    const sx = getRandomInt(0, 19);
    const sy = getRandomInt(0, 19);

    await new Game(sx, sy).start();

    console.log("\n\nPress 'R' to Retry or 'Q' to Quit...");

    const retryDecision = await waitForMenuInput(retry);
    if (retryDecision === "quit") {
        playAgain = false;
        break;
    }
}

hideCursor();

console.log("\nThanks for playing!");

for (let i = 5; i >= 0; --i) {
    process.stdout.write(`\rClosing in ${i} seconds...`);
    await sleep_s(1);
}

showCursor();
process.exit(0);
