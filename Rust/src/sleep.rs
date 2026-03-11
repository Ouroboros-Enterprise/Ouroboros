use std::thread;
use std::time::Duration;

#[inline(always)]
pub fn sleep_ms(milliseconds: u64) {
    thread::sleep(Duration::from_millis(milliseconds));
}

#[inline(always)]
pub fn sleep_s(seconds: u64) {
    thread::sleep(Duration::from_secs(seconds));
}
