use std::io::{self, Write};

pub fn goto_xy(x: i32, y: i32) {
    print!("\x1B[{};{}H", y, x);
    let _ = io::stdout().flush();
}

pub fn hide_cursor() {
    print!("\x1B[?25l");
    let _ = io::stdout().flush();
}

pub fn show_cursor() {
    print!("\x1B[?25h");
    let _ = io::stdout().flush();
}

pub fn clear_display() {
    print!("\x1B[2J\x1B[H");
    let _ = io::stdout().flush();
}
