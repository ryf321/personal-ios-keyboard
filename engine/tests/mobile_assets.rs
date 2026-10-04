//! 随包 mmap 词库的真实数据验证，防止样例通过而产品资源不能加载。
use qingjian_ios::{qj_create, qj_destroy, qj_dispatch, qj_string_free};
use std::ffi::{CStr, CString};

#[test]
fn packed_mobile_dictionary_supplies_chinese_and_english_glosses() {
    let root = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("ios/Resources");
    if !root.join("dict.qj").is_file() {
        // 源码检出后由 pack 生成；CI 会在此测试前先打包资源。
        panic!("run cargo run -p qingjian-ios --bin pack -- ios/Resources first");
    }
    let dict = CString::new(root.join("dict.qj").to_str().unwrap()).unwrap();
    let gloss = CString::new(root.join("glossary-en.qj").to_str().unwrap()).unwrap();
    unsafe {
        let h = qj_create(dict.as_ptr(), gloss.as_ptr());
        assert!(!h.is_null(), "packed resources must load");
        for (pinyin, expected) in [
            ("kaifa", "开发"),
            ("nihao", "你好"),
            ("gongzuo", "工作"),
            ("xuexi", "学习"),
        ] {
            let clear = CString::new("clear").unwrap();
            qj_string_free(qj_dispatch(h, clear.as_ptr(), 0, 0));
            let mut frame = serde_json::Value::Null;
            for c in pinyin.chars() {
                let action = CString::new(c.to_string()).unwrap();
                let result = qj_dispatch(h, action.as_ptr(), 0, 0);
                assert!(!result.is_null());
                frame = serde_json::from_slice(CStr::from_ptr(result).to_bytes()).unwrap();
                qj_string_free(result);
            }
            let candidate = frame["candidates"]
                .as_array()
                .unwrap()
                .iter()
                .find(|c| c["text"] == expected)
                .unwrap();
            assert!(
                !candidate["gloss"].as_str().unwrap().is_empty(),
                "{expected} needs English annotation"
            );
        }
        qj_destroy(h);
    }
}
