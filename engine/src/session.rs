//! 持有引擎与最近候选；候选选择带版本号，拒绝快速敲键期间的过期点击。
use crate::frame::{DisplayCandidate, Frame};
use qingjian_core::{Candidate, Engine, Language};
use qingjian_dictionary::Dictionary;
use qingjian_translate::Glossary;

pub struct Session {
    engine: Engine,

    candidates: Vec<Candidate>,

    revision: u64,
}

impl Session {
    pub fn from_paths(dict: &str, gloss: &str) -> Option<Self> {
        let dictionary = Dictionary::from_path(dict).ok()?;
        let glossary = Glossary::from_path(Language::English, gloss).ok()?;
        let mut engine = Engine::new(dictionary).with_translator(Box::new(glossary));
        // 第一版不记录输入、不联网、不写学习数据。
        engine.set_private(true);
        Some(Self {
            engine,
            candidates: Vec::new(),
            revision: 0,
        })
    }

    pub fn dispatch(&mut self, action: &str, index: usize, revision: u64) -> Frame {
        let mut committed = String::new();
        let mut error = None;
        let mut delete_backward = false;
        match action {
            "refresh" => {}
            "clear" => self.engine.discard_input(),
            "backspace" => {
                delete_backward = !self.engine.backspace();
            }
            "raw" => {
                committed = self.engine.composition().text().to_owned();
                self.engine.clear();
            }
            "select" | "first" => {
                if action == "select" && revision != self.revision {
                    error = Some("候选已更新，请重新选择".into());
                } else if let Some(candidate) = self.candidates.get(index).cloned() {
                    committed = self.engine.commit(&candidate);
                } else if action == "first" {
                    committed = self.engine.composition().text().to_owned();
                    self.engine.clear();
                }
            }
            key if key.len() == 1 && (key.as_bytes()[0].is_ascii_lowercase() || key == "'") => {
                if self.engine.composition().text().len() < 64 {
                    self.engine
                        .push(key.chars().next().expect("single ASCII key"));
                }
            }
            _ => error = Some("不支持的按键".into()),
        }
        self.revision += 1;
        let mut preedit = self.engine.composition().text().to_owned();
        self.candidates.clear();
        if !preedit.is_empty() {
            match self.engine.query() {
                Ok(mut query) => {
                    query.candidates.items.truncate(30);
                    preedit = query.marked_text();
                    self.engine.annotate(&mut query.candidates);
                    self.candidates = query.candidates.items;
                }
                Err(_) => error = Some("请选词或按回车提交拼音".into()),
            }
        }
        let candidates = self
            .candidates
            .iter()
            .map(|candidate| DisplayCandidate {
                text: candidate.text.clone(),
                gloss: candidate
                    .translation
                    .as_ref()
                    .and_then(|t| t.senses().first())
                    .map(|s| s.text.clone())
                    .unwrap_or_default(),
            })
            .collect();
        Frame {
            revision: self.revision,
            preedit,
            candidates,
            committed,
            delete_backward,
            error,
        }
    }
}
