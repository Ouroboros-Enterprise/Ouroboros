package com.ouroboros.include;

public class Snake {
    public Node head;

    public Snake(int x, int y, Node next) {
        head = new Node(x, y, next);
    }

    public boolean move(int x, int y, boolean grow) {
        Node old_head = new Node(head.x, head.y, head.next);
        head.next = old_head;

        head.x = x;
        head.y = y;

        if (!grow && head.next != null) {
            Node curr = head;

            while (curr.next != null && curr.next.next != null) {
                curr = curr.next;
            }
            curr.next = null;
        }

        return !wallCollison() && !selfCollision();
    }

    private boolean wallCollison() {
        int x = head.x;
        int y = head.y;

        return x < 0 || x >= 20 || y < 0 || y >= 20;
    }

    private boolean selfCollision() {
        for (Node node : head) {
            if (node == head) {
                continue;
            }
            if (node.x == head.x && node.y == head.y) {
                return true;
            }
        }
        return false;
    }
}
