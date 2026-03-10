#ifndef INPUT_H
#define INPUT_H

#include "makros.h"

#ifdef _WIN32
#include <conio.h>
#else
#include <fcntl.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#endif

// static hinzufügen für Header-Inlines
static ALWAYS_INLINE int get_key_press(void)
{
#ifdef _WIN32
    if (_kbhit())
    {
        return _getch();
    }
    return -1;
#else
    struct termios oldt, newt;
    int ch;
    int oldf;

    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    // ICANON ausschalten (kein Warten auf Enter) und ECHO (keine Anzeige der Taste)
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

    ch = getchar();

    // Terminal-Einstellungen sofort wiederherstellen
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    fcntl(STDIN_FILENO, F_SETFL, oldf);

    return ch;
#endif
}

#endif // INPUT_H
