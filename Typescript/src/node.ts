export default class Node implements Iterable<Node> {
    constructor(
        public x: number,
        public y: number,
        public next: Node | null,
    ) {}

    *[Symbol.iterator](): Iterator<Node> {
        let curr: Node | null = this;
        while (curr) {
            yield curr;
            curr = curr.next;
        }
    }
}
