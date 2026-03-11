use crate::node::Node;

pub struct Snake {
    pub head: Box<Node>,
}

impl Snake {
    pub fn new(x: i32, y: i32, next: Option<Box<Node>>) -> Self {
        let head: Box<Node> = Box::new(Node::new(x, y, next));
        Snake { head }
    }

    fn wall_collision(&self) -> bool {
        let x: i32 = self.head.x;
        let y: i32 = self.head.y;

        x < 0 || x >= 20 || y < 0 || y >= 20
    }

    fn self_collision(&self) -> bool {
        let x: i32 = self.head.x;
        let y: i32 = self.head.y;

        let mut curr: Option<&Node> = self.head.next.as_deref();

        while let Some(node) = curr {
            if node.x == x && node.y == y {
                return true;
            }
            curr = node.next.as_deref();
        }

        false
    }

    fn remove_tail(&mut self) {
        if self.head.next.is_none() {
            return;
        }

        let mut curr: &mut Box<Node> = &mut self.head;

        while curr.next.as_ref().unwrap().next.is_some() {
            curr = curr.next.as_mut().unwrap();
        }

        curr.next = None;
    }

    pub fn move_snake(&mut self, nx: i32, ny: i32, grow: bool) -> bool {
        let old_body: Option<Box<Node>> = std::mem::take(&mut self.head.next);

        let old_head: Box<Node> = Box::new(Node::new(self.head.x, self.head.y, old_body));

        self.head.next = Some(old_head);

        self.head.x = nx;
        self.head.y = ny;

        if !grow {
            self.remove_tail();
        }

        !self.wall_collision() && !self.self_collision()
    }
}
