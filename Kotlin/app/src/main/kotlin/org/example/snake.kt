package org.example

class Snake(x: Int, y: Int, next: Node) {
    var head: Node

    init {
        head = Node(x, y, next)
    }

    public fun move(x: Int, y: Int, grow: Boolean): Boolean {
        val old_head = Node(head.x, head.y, head.next)
        head.next = old_head

        head.x = x
        head.y = y

        if (!grow && head.next != null) {
            var curr = head

            while(curr.next?.next != null) {
                val next = curr.next ?: break
                curr = next
            }
            curr.next = null
        }
        return !wallCollision() && !selfCollision()
    }

    private fun wallCollision(): Boolean {
        val x = head.x
        val y = head.y
        
        return x < 0 || x >= 20 || y < 0 || y >= 20
    }

    private fun selfCollision(): Boolean {
        for (node in head) {
            if (node == head) {
                continue
            }
            if (node.x == head.x && node.y == head.y) {
                return true
            }
        }
        return false
    }
}