//! 键盘显示帧；提交文本与剩余拼音一起返回，避免壳自行推算音节消耗。
use serde::Serialize;

#[derive(Serialize)]
pub struct Frame {
    pub revision: u64,

    pub preedit: String,

    pub candidates: Vec<DisplayCandidate>,

    pub committed: String,

    pub delete_backward: bool,

    pub error: Option<String>,
}

#[derive(Serialize)]
pub struct DisplayCandidate {
    pub text: String,

    pub gloss: String,
}
