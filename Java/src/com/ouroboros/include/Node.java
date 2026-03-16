package com.ouroboros.include;

import java.util.Iterator;

public class Node implements Iterable<Node> {
    public int x, y;
    public Node next;

    public Node(int x, int y, Node next) {
        this.x = x;
        this.y = y;
        this.next = next;
    }

    @Override
    public Iterator<Node> iterator() {
        return new Iterator<Node>() {
            private Node curr = Node.this;

            @Override
            public boolean hasNext() {
                return curr != null;
            }

            @Override
            public Node next() {
                if (!hasNext())
                    throw new java.util.NoSuchElementException();
                Node tmp = curr;
                curr = curr.next;
                return tmp;
            }
        };
    }
}
