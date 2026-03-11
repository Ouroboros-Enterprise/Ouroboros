use std::io::{self, Write};

use crate::{
    game::Game,
    input::get_key_press,
    rng::get_random_int,
    sleep::{sleep_ms, sleep_s},
    terminal::{clear_display, hide_cursor, show_cursor},
};

mod apple;
mod game;
mod gui;
mod input;
mod node;
mod rng;
mod sleep;
mod snake;
mod terminal;

fn main() {
    let mut play_again: bool = true;

    let start: [u8; 2] = [b' ', 13];
    let quit: [u8; 3] = [b'q', b'Q', 27];
    let retry: [u8; 2] = [b'r', b'R'];

    while play_again {
        clear_display();
        println!("--- OUROBOROS Rust ---");
        println!("Press SPACE to start or 'Q' to Quit...");

        loop {
            let input: u8 = get_key_press() as u8;

            if start.contains(&input) {
                break;
            }

            if quit.contains(&input) {
                play_again = false;
                break;
            }

            sleep_ms(10);
        }

        if !play_again {
            break;
        }

        let start_x: i32 = get_random_int(0, 19);
        let start_y: i32 = get_random_int(0, 19);

        let mut game: Game = Game::new(start_x, start_y);

        game.start();

        println!("\n\nPress 'R' to Retry or 'Q' to Quit...");

        loop {
            let input: u8 = get_key_press() as u8;

            if retry.contains(&input) {
                play_again = true;
                break;
            }

            if quit.contains(&input) {
                play_again = false;
                break;
            }

            sleep_ms(10);
        }
    }

    hide_cursor();
    println!("\nThanks for playing!\n");

    for i in (0..=5).rev() {
        print!("\rClosing in {} seconds...", i);
        io::stdout().flush().unwrap();
        sleep_s(1);
    }
    show_cursor();
    println!();
}
