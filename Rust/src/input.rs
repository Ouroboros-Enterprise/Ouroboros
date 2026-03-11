#[cfg(windows)]
unsafe extern "C" {
    unsafe fn _kbhit() -> i32;
    unsafe fn _getch() -> i32;
}

#[cfg(unix)]
use select::select;
#[cfg(unix)]
use std::io::{self, Read, Write};
#[cfg(unix)]
use std::os::unix::io::AsRawFd;
#[cfg(unix)]
use termios::{ECHO, ICANON, TCSANOW, Termios, tcgetattr, tcsetattr};

/// Prüft, ob eine Taste gedrückt wurde, und gibt den ASCII-Wert zurück.
/// Gibt -1 zurück, wenn kein Input vorliegt.
pub fn get_key_press() -> i32 {
    #[cfg(windows)]
    unsafe {
        if _kbhit() != 0 {
            return _getch();
        }
        -1
    }

    #[cfg(unix)]
    {
        let fd = io::stdin().as_raw_fd();
        let mut termios = Termios::from_fd(fd).unwrap();
        let old_termios = termios.clone();

        // Raw Mode aktivieren
        termios.c_lflag &= !(ICANON | ECHO);
        tcsetattr(fd, TCSANOW, &termios).unwrap();

        let mut buf = [0u8; 1];
        let mut read_fds = select::FdSet::new();
        read_fds.insert(fd);

        let mut timeout = select::TimeVal::new(0, 0);
        let result = select::select(
            Some(fd + 1),
            Some(&mut read_fds),
            None,
            None,
            Some(&mut timeout),
        );

        let key = if let Ok(1) = result {
            io::stdin().read_exact(&mut buf).unwrap();
            buf[0] as i32
        } else {
            -1
        };

        // Terminal zurücksetzen
        tcsetattr(fd, TCSANOW, &old_termios).unwrap();
        key
    }
}

/// Wartet auf einen finalen Tastendruck.
pub fn wait_for_exit() {
    println!("\nDruecke eine Taste zum Beenden...");
    #[cfg(windows)]
    unsafe {
        while _kbhit() != 0 {
            _getch();
        }
        _getch();
    }

    #[cfg(unix)]
    {
        let _ = get_key_press(); // Nutzt die obige Logik für Single-Key
    }
}
