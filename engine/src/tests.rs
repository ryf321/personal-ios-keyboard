//! 真实核心的桥接回归：部分候选上屏、过期点击、边界退格与 C 字符串所有权。
use crate::{qj_create, qj_destroy, qj_dispatch, qj_string_free};
use std::ffi::{CStr, CString};

fn with_engine(test: impl FnOnce(*mut crate::session::Session)) {
    let folder = std::env::temp_dir().join(format!(
        "qj-ios-{}-{:?}",
        std::process::id(),
        std::thread::current().id()
    ));
    std::fs::create_dir_all(&folder).unwrap();
    std::fs::write(
        folder.join("dict.tsv"),
        "开发\tkai fa\t9000\n开发者\tkai fa zhe\t3000\n开\tkai\t800\n你好\tni hao\t9000\n",
    )
    .unwrap();
    std::fs::write(
        folder.join("gloss.tsv"),
        "开发\tv. develop\n开发者\tn. developer\n你好\thello\n",
    )
    .unwrap();
    let dict = CString::new(folder.join("dict.tsv").to_str().unwrap()).unwrap();
    let gloss = CString::new(folder.join("gloss.tsv").to_str().unwrap()).unwrap();
    unsafe {
        let handle = qj_create(dict.as_ptr(), gloss.as_ptr());
        assert!(!handle.is_null());
        test(handle);
        qj_destroy(handle);
    }
    std::fs::remove_dir_all(folder).unwrap();
}

fn send(
    handle: *mut crate::session::Session,
    action: &str,
    index: usize,
    revision: u64,
) -> serde_json::Value {
    let action = CString::new(action).unwrap();
    unsafe {
        let result = qj_dispatch(handle, action.as_ptr(), index, revision);
        assert!(!result.is_null());
        let frame = serde_json::from_slice(CStr::from_ptr(result).to_bytes()).unwrap();
        qj_string_free(result);
        frame
    }
}

#[test]
fn partial_commit_keeps_remaining_pinyin_and_gloss() {
    with_engine(|h| {
        let mut frame = send(h, "refresh", 0, 0);
        for c in "kaifazhe".chars() {
            frame = send(h, &c.to_string(), 0, 0);
        }
        let candidates = frame["candidates"].as_array().unwrap();
        let index = candidates.iter().position(|c| c["text"] == "开发").unwrap();
        assert_eq!(candidates[index]["gloss"], "develop");
        let frame = send(h, "select", index, frame["revision"].as_u64().unwrap());
        assert_eq!(frame["committed"], "开发");
        assert_eq!(frame["preedit"], "zhe");
    });
}

#[test]
fn stale_selection_never_commits_new_candidate() {
    with_engine(|h| {
        let old = send(h, "k", 0, 0)["revision"].as_u64().unwrap();
        send(h, "a", 0, 0);
        let result = send(h, "select", 0, old);
        assert_eq!(result["committed"], "");
        assert!(result["error"].is_string());
    });
}

#[test]
fn backspace_only_deletes_host_text_when_composition_is_empty() {
    with_engine(|h| {
        send(h, "n", 0, 0);
        assert_eq!(send(h, "backspace", 0, 0)["delete_backward"], false);
        assert_eq!(send(h, "backspace", 0, 0)["delete_backward"], true);
    });
}

#[test]
fn raw_commit_clear_and_new_session_are_independent() {
    with_engine(|h| {
        send(h, "a", 0, 0);
        assert_eq!(send(h, "raw", 0, 0)["committed"], "a");
        assert_eq!(send(h, "refresh", 0, 0)["preedit"], "");
        send(h, "k", 0, 0);
        assert_eq!(send(h, "clear", 0, 0)["preedit"], "");
        assert_eq!(send(h, "first", 0, 0)["committed"], "");
    });
}

#[test]
fn missing_assets_and_null_inputs_fail_safely() {
    unsafe {
        assert!(qj_create(std::ptr::null(), std::ptr::null()).is_null());
        let key = CString::new("refresh").unwrap();
        assert!(qj_dispatch(std::ptr::null_mut(), key.as_ptr(), 0, 0).is_null());
        qj_destroy(std::ptr::null_mut());
        qj_string_free(std::ptr::null_mut());
    }
}
