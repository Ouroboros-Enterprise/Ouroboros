package org.example

import kotlin.random.Random

class Apple(snake: Snake) {
    var x: Int = 0
    var y: Int = 0

    init {
        eat(snake)
    }

    public fun eat(snake: Snake) {
        repeat(1000) {
            var blocked = false
            val rx = Random.nextInt(0, 20)
            val ry = Random.nextInt(0, 20)

            for (node in snake.head) {
                if (node.x == rx && node.y == ry) {
                    blocked = true
                    break
                }
            }

            if (!blocked) {
                x = rx
                y = ry
                return
            }
        }
    }
}