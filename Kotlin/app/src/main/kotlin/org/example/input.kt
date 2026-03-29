package org.example

import java.awt.event.KeyAdapter
import java.awt.event.KeyEvent
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import javax.swing.JFrame
import javax.swing.SwingUtilities

object Input {
    private val keyQueue: BlockingQueue<String> = LinkedBlockingQueue()
    private var inputFrame: JFrame? = null

    init {
        // In Kotlin nutzt man init statt static-Blöcken
        SwingUtilities.invokeLater {
            val frame = JFrame("Ouroboros Input")
            inputFrame = frame
            
            frame.apply {
                setSize(1, 1)
                isUndecorated = true
                opacity = 0.01f
                setLocation(-100, -100)
                defaultCloseOperation = JFrame.DISPOSE_ON_CLOSE
                
                addKeyListener(object : KeyAdapter() {
                    override fun keyPressed(e: KeyEvent) {
                        // Kotlin 'when' statt Java 'switch'
                        val input = when (e.keyCode) {
                            KeyEvent.VK_UP -> "\u001b[A"
                            KeyEvent.VK_DOWN -> "\u001b[B"
                            KeyEvent.VK_LEFT -> "\u001b[D"
                            KeyEvent.VK_RIGHT -> "\u001b[C"
                            KeyEvent.VK_W -> "w"
                            KeyEvent.VK_A -> "a"
                            KeyEvent.VK_S -> "s"
                            KeyEvent.VK_D -> "d"
                            KeyEvent.VK_SPACE -> " "
                            KeyEvent.VK_ENTER -> "\n"
                            KeyEvent.VK_Q -> "q"
                            KeyEvent.VK_R -> "r"
                            KeyEvent.VK_ESCAPE -> "\u001b"
                            else -> null
                        }

                        input?.let { keyQueue.offer(it) }
                    }
                })

                isVisible = true
                requestFocus()
            }
        }
    }

    fun getKeyPress(): String? {
        return keyQueue.poll() // Gibt null zurück, wenn keine Taste gedrückt wurde
    }

    fun close() {
        inputFrame?.dispose()
    }

    fun waitForExit() {
        println("Press a key to exit...")
        try {
            keyQueue.take() // Blockiert, bis eine Taste in der Queue landet
        } catch (e: InterruptedException) {
            Thread.currentThread().interrupt()
        }
    }
}