import Node from "./node.js";

export default class Snake {
    public head: Node;

    constructor(x: number, y: number, next: Node) {
        this.head = new Node(x, y, next);
    }

    public move(x: number, y: number, grow: boolean): boolean {
        const old_head = new Node(this.head.x, this.head.y, this.head.next);
        this.head.next = old_head;

        this.head.x = x;
        this.head.y = y;

        if (!grow && this.head.next != null) {
            let curr = this.head;

            while (curr.next != null && curr.next.next != null) {
                curr = curr.next;
            }
            curr.next = null;
        }
        return !this.wallCollision() && !this.selfCollision();
    }

    private wallCollision(): boolean {
        const x = this.head.x;
        const y = this.head.y;

        return x < 0 || x >= 20 || y < 0 || y >= 20;
    }

    private selfCollision(): boolean {
        for (const node of this.head) {
            if (node == this.head) continue;

            if (node.x == this.head.x && node.y == this.head.y) {
                return true;
            }
        }
        return false;
    }
}
