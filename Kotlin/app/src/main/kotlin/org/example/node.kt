package org.example

import java.util.NoSuchElementException

data class Node(
    var x: Int,
    var y: Int, 
    var next: Node? = null
) : Iterable<Node> {
    override fun iterator(): Iterator<Node> = object : Iterator<Node> {
        var curr: Node? = this@Node

        override fun hasNext(): Boolean = curr != null

        override fun next(): Node {
            val res = curr ?: throw NoSuchElementException()
            curr = res.next
            return res
        }
    }
}