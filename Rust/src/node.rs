pub struct Node {
    pub x: i32,
    pub y: i32,
    pub next: Option<Box<Node>>,
}

impl Node {
    pub fn new(x: i32, y: i32, next: Option<Box<Node>>) -> Self {
        Node { x, y, next }
    }
}
