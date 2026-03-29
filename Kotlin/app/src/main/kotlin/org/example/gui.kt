package org.example

class GUI {
    private var map = Array(22) { CharArray(22) { ' ' } }

    public fun genGui(snake: Snake, apple: Apple, score: Int) {
        Terminal.gotoXY(1, 1)
        
        for (row in map) {
            row.fill(' ')
        }

        placeBorders()
        placeSnake(snake)
        placeApple(apple)
        
        val out = StringBuilder()

        for (j in 0..21) {
            for (i in 0..21) {
                val field = map[i][j]

                if (field == '#') {
                    out.append("##")
                } else {
                    out.append("$field ")
                }
            }

            if (j == 0) {
                out.append("  Score:  $score")
            }

            out.append("\n")
        }

        print(out.toString())
    }

    public fun gameOver() {
        Terminal.gotoXY(1, 23)

        println("         ___                 ")
        println("        / __|__ _ _ __  ___  ")
        println("       | (_ / _` | ''  \\/ -_) ")
        println("        \\___\\__,_|_|_|_\\___| ")
        println("         ___                 ")
        println("        / _ \\_ _____ _ _     ")
        println("       | (_) \\ V / -_) ''_|   ")
        println("        \\___/ \\_/\\___|_|     ")
    }

    private fun placeBorders() {
        for (i in 0..21) {
            map[0][i] = '#'
            map[21][i] = '#'
            map[i][0] = '#'
            map[i][21] = '#'
        }
    }

    private fun placeSnake(snake: Snake) {
        for (node in snake.head) {
            if (node == snake.head) {
                map[node.x + 1][node.y + 1] = 'X'
            } else {
                map[node.x + 1][node.y + 1] = 'O'
            }
        }
    }

    private fun placeApple(apple: Apple) {
        map[apple.x + 1][apple.y + 1] = '@'
    }
}