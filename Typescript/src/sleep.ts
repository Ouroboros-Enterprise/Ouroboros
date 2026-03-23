export const sleep_ms = (ms: number) =>
    new Promise((resolve) => setTimeout(resolve, ms));

export const sleep_s = (s: number) => sleep_ms(s * 1000);
