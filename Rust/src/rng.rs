use rand::Rng;

#[inline(always)]
pub fn get_random_int(min: i32, max: i32) -> i32 {
    if min >= max {
        return min;
    }
    let mut rng = rand::thread_rng();

    rng.gen_range(min..=max)
}
