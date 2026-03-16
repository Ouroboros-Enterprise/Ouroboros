package com.ouroboros.include;

import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import javax.swing.JFrame;
import javax.swing.SwingUtilities;

public class Input {
    private static final BlockingQueue<String> keyQueue = new LinkedBlockingQueue<>();
    private static final JFrame inputFrame = new JFrame("Ouroboros Input");

    static {
        SwingUtilities.invokeLater(() -> {
            inputFrame.setSize(1, 1);

            inputFrame.setUndecorated(true);

            inputFrame.setOpacity(0.01f);

            inputFrame.setLocation(-100, -100);

            // DISPOSE instead of EXIT: Only the window will be destroyed, not the JVM
            inputFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);

            inputFrame.addKeyListener(new KeyAdapter() {
                @Override
                public void keyPressed(KeyEvent e) {
                    String input = switch (e.getKeyCode()) {
                        case KeyEvent.VK_UP -> "\033[A";
                        case KeyEvent.VK_DOWN -> "\033[B";
                        case KeyEvent.VK_LEFT -> "\033[D";
                        case KeyEvent.VK_RIGHT -> "\033[C";
                        case KeyEvent.VK_W -> "w";
                        case KeyEvent.VK_A -> "a";
                        case KeyEvent.VK_S -> "s";
                        case KeyEvent.VK_D -> "d";
                        case KeyEvent.VK_SPACE -> " ";
                        case KeyEvent.VK_ENTER -> "\n";
                        case KeyEvent.VK_Q -> "q";
                        case KeyEvent.VK_R -> "r";
                        case KeyEvent.VK_ESCAPE -> "\033";
                        default -> null;
                    };

                    if (input != null) {
                        keyQueue.offer(input);
                    }
                }
            });

            inputFrame.setVisible(true);
            inputFrame.requestFocus();
        });
    }

    public static String getKeyPress() {
        return keyQueue.poll();
    }

    public static void close() {
        if (inputFrame != null) {
            inputFrame.dispose();
        }
    }

    public static void waitForExit() {
        System.out.println("Press a key to exit...");
        try {
            keyQueue.take();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
