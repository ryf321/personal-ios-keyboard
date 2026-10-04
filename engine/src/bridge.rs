//! C ABI 的字符串所有权：返回的 JSON 用 qj_string_free 释放；失败返回空指针。
use crate::session::Session;
use std::ffi::{CStr, CString, c_char};
use std::panic::{AssertUnwindSafe, catch_unwind};
use std::ptr;

unsafe fn read_string<'a>(value: *const c_char) -> Option<&'a str> {
    if value.is_null() {
        return None;
    }
    unsafe { CStr::from_ptr(value) }.to_str().ok()
}

/// # Safety
/// 两个参数必须是有效的 NUL 结尾 UTF-8 字符串，至少活到调用结束。
#[unsafe(no_mangle)]
pub unsafe extern "C" fn qj_create(dict: *const c_char, gloss: *const c_char) -> *mut Session {
    catch_unwind(AssertUnwindSafe(|| {
        let Some(dict) = (unsafe { read_string(dict) }) else {
            return ptr::null_mut();
        };
        let Some(gloss) = (unsafe { read_string(gloss) }) else {
            return ptr::null_mut();
        };
        Session::from_paths(dict, gloss).map_or(ptr::null_mut(), |s| Box::into_raw(Box::new(s)))
    }))
    .unwrap_or(ptr::null_mut())
}

/// # Safety
/// handle 必须来自 qj_create；action 必须是有效字符串；同一 handle 不可并发调用。
#[unsafe(no_mangle)]
pub unsafe extern "C" fn qj_dispatch(
    handle: *mut Session,
    action: *const c_char,
    index: usize,
    revision: u64,
) -> *mut c_char {
    if handle.is_null() {
        return ptr::null_mut();
    }
    catch_unwind(AssertUnwindSafe(|| {
        let action = unsafe { read_string(action) }?;
        let frame = unsafe { &mut *handle }.dispatch(action, index, revision);
        CString::new(serde_json::to_string(&frame).ok()?)
            .ok()
            .map(CString::into_raw)
    }))
    .ok()
    .flatten()
    .unwrap_or(ptr::null_mut())
}

/// # Safety
/// handle 必须来自 qj_create 且尚未释放，释放前所有调用必须完成。
#[unsafe(no_mangle)]
pub unsafe extern "C" fn qj_destroy(handle: *mut Session) {
    if !handle.is_null() {
        drop(unsafe { Box::from_raw(handle) });
    }
}

/// # Safety
/// value 必须是 qj_dispatch 返回的尚未释放的非空指针，或空指针。
#[unsafe(no_mangle)]
pub unsafe extern "C" fn qj_string_free(value: *mut c_char) {
    if !value.is_null() {
        drop(unsafe { CString::from_raw(value) });
    }
}
