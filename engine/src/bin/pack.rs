//! 把手机词库与释义打包为 mmap 容器，避免键盘启动时解析 TSV 的内存峰值。
use qingjian_core::Language;
use qingjian_dictionary::Dictionary;
use qingjian_format::Metadata;
use qingjian_translate::Glossary;
use std::path::Path;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = std::env::args()
        .nth(1)
        .expect("resource directory argument");
    let root = Path::new(&root);
    Dictionary::from_path(root.join("dict.tsv"))?
        .write_qj(&root.join("dict.qj"), &Metadata::default())?;
    Glossary::from_path(Language::English, root.join("glossary-en.tsv"))?
        .write_qj(&root.join("glossary-en.qj"), &Metadata::default())?;
    Ok(())
}
