import readline from "node:readline";

export class Input {
    public static async waitForKey(
        intercept: boolean = true,
    ): Promise<readline.Key> {
        readline.emitKeypressEvents(process.stdin);
        process.stdin.removeAllListeners("keypress");

        const wasRaw = process.stdin.isRaw;
        process.stdin.setRawMode(true);
        process.stdin.resume();

        return new Promise((resolve) => {
            process.stdin.once("keypress", (str: string, key: readline.Key) => {
                if (key.ctrl && key.name === "c") {
                    process.exit();
                }

                process.stdin.setRawMode(wasRaw);
                process.stdin.pause();

                resolve(key);
            });
        });
    }

    public static async waitForExit(
        message: string = "Press a key to exit...",
    ): Promise<void> {
        console.log(message);
        await this.waitForKey(true);
    }
}
