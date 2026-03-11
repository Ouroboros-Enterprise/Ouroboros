use crate::{rng::get_random_int, snake::Snake};

pub struct Apple {
    pub x: i32,
    pub y: i32,
}

impl Apple {
    pub fn new(snake: &Snake) -> Self {
        let mut apple = Apple { x: 0, y: 0 };
        apple.eat(snake);
        apple
    }

    pub fn eat(&mut self, snake: &Snake) {
        for _ in 0..1000 {
            let x: i32 = get_random_int(0, 19);
            let y: i32 = get_random_int(0, 19);

            let mut blocked: bool = false;
            let mut curr: Option<&crate::node::Node> = Some(&*snake.head);

            while let Some(node) = curr {
                if node.x == x && node.y == y {
                    blocked = true;
                    break;
                }
                curr = node.next.as_deref();
            }

            if !blocked {
                self.x = x;
                self.y = y;
                break;
            }
        }
    }
}
