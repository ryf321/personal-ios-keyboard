//! iOS 的 C ABI 入口；所有指针由调用方在同一个串行队列上使用。
mod bridge;
mod frame;
mod session;

pub use bridge::{qj_create, qj_destroy, qj_dispatch, qj_string_free};

#[cfg(test)]
mod tests;
