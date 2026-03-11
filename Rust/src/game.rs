use crate::{
    apple::Apple,
    gui::GUI,
    input::{get_key_press, wait_for_exit},
    node::Node,
    sleep::sleep_ms,
    snake::Snake,
    terminal::{hide_cursor, show_cursor},
};

pub struct Game {
    apple_count: i32,
    snake: Snake,
    apple: Apple,
    gui: GUI,
}

impl Game {
    pub fn new(start_x: i32, start_y: i32) -> Self {
        let second_node: Box<Node> = Box::new(Node::new(start_x, start_y + 1, None));
        let snake: Snake = Snake::new(start_x, start_y, Some(second_node));
        let apple: Apple = Apple::new(&snake);
        let gui: GUI = GUI::new();

        Game {
            apple_count: 0,
            snake,
            apple,
            gui,
        }
    }

    pub fn start(&mut self) {
        hide_cursor();

        let mut dx: i32 = 1;
        let mut dy: i32 = 0;
        let mut running: bool = true;

        loop {
            let input: i32 = get_key_press();

            match input as u8 {
                b'w' | b'W' | 72 => {
                    if dy != 1 {
                        dx = 0;
                        dy = -1;
                    }
                }
                b's' | b'S' | 80 => {
                    if dy != -1 {
                        dx = 0;
                        dy = 1;
                    }
                }
                b'a' | b'A' | 75 => {
                    if dx != 1 {
                        dx = -1;
                        dy = 0;
                    }
                }
                b'd' | b'D' | 77 => {
                    if dx != -1 {
                        dx = 1;
                        dy = 0;
                    }
                }
                b'q' | b'Q' | 27 => {
                    running = false;
                }
                _ => {}
            }

            if !running {
                break;
            }

            let ax: i32 = self.snake.head.x + dx;
            let ay: i32 = self.snake.head.y + dy;

            let grow: bool = ax == self.apple.x && ay == self.apple.y;
            if grow {
                self.apple.eat(&self.snake);
                self.apple_count += 1;
            }

            if !self.snake.move_snake(ax, ay, grow) {
                break;
            }

            self.gui.gen_gui(&self.snake, &self.apple, self.apple_count);

            sleep_ms(300);
        }
        GUI::game_over();
        show_cursor();
        wait_for_exit();
    }
}
