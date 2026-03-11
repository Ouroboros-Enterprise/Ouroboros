use std::io::{self, Write};

use crate::apple::Apple;
use crate::node::Node;
use crate::snake::Snake;
use crate::terminal::goto_xy;

pub struct GUI {
    pub map: [[u8; 22]; 22],
}

impl GUI {
    pub fn new() -> Self {
        GUI { map: [[0; 22]; 22] }
    }

    fn place_borders(&mut self) {
        for i in 0..22 {
            self.map[0][i] = b'#';
            self.map[21][i] = b'#';
            self.map[i][0] = b'#';
            self.map[i][21] = b'#';
        }
    }

    fn place_snake(&mut self, snake: &Snake) {
        let head: &Box<Node> = &snake.head;
        self.map[(head.x + 1) as usize][(head.y + 1) as usize] = b'X';

        let mut curr: Option<&crate::node::Node> = head.next.as_deref();

        while let Some(node) = curr {
            let x: usize = (node.x + 1) as usize;
            let y: usize = (node.y + 1) as usize;

            if x < 22 && y < 22 {
                self.map[x][y] = b'O';
            }
            curr = node.next.as_deref();
        }
    }

    fn place_apple(&mut self, apple: &Apple) {
        let x: usize = (apple.x + 1) as usize;
        let y: usize = (apple.y + 1) as usize;

        if x < 22 && y < 22 {
            self.map[x][y] = b'@';
        }
    }

    pub fn gen_gui(&mut self, snake: &Snake, apple: &Apple, score: i32) {
        goto_xy(1, 1);

        self.map = [[b' '; 22]; 22];

        self.place_borders();
        self.place_snake(snake);
        self.place_apple(apple);

        for j in 0..22 {
            for i in 0..22 {
                let field: u8 = self.map[i][j];

                if field == b'#' {
                    print!("##");
                } else {
                    print!("{} ", field as char);
                }
            }

            if j == 0 {
                print!("  Score:  {}", score);
            }

            println!();
        }

        io::stdout().flush().unwrap();
    }

    pub fn game_over() {
        goto_xy(1, 23);

        println!("         ___                 ");
        println!("        / __|__ _ _ __  ___  ");
        println!("       | (_ / _` | ''  \\/ -_) ");
        println!("        \\___\\__,_|_|_|_\\___| ");
        println!("         ___                 ");
        println!("        / _ \\_ _____ _ _     ");
        println!("       | (_) \\ V / -_) ''_|   ");
        println!("        \\___/ \\_/\\___|_|     ");
    }
}
