export const gotoXY = (x: number, y: number) => {
    process.stdout.write(`\x1B[${y};${x}H`);
};

export const hideCursor = () => {
    process.stdout.write("\x1B[?25l");
};

export const showCursor = () => {
    process.stdout.write("\x1B[?25h");
};

export const clearDisplay = () => {
    process.stdout.write("\x1B[2J\x1B[H");
};
