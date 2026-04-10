#include <unistd.h>

void sleep_ms_c(int ms) {
    usleep(ms * 1000);
}

void sleep_s_c(int s) {
    sleep(s);
}
