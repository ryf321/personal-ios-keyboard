#!/usr/bin/env python3
"""下载固定上游版本的数据，校验后筛出手机使用的英文释义；只在构建时联网。"""
from pathlib import Path
import hashlib
import urllib.request

ROOT = Path(__file__).resolve().parent.parent
RESOURCE_DIR = ROOT / 'ios/Resources'
REVISION = 'c08ae57cb88b6a4a46f4a5e9c1d6d11c5e69222e'
SOURCES = {
    'assets/lexicon/dict.tsv': '7787d6d219674dd51297652456c55ea2d49a65b5e571d2309a62add0ec2d2279',
    'assets/glossary/glossary-en.tsv': '7b9676979aa227bde7a2d541354a59b73a04f33acd36ef5d6c433ce789b81625',
}


def fetch(path: str) -> bytes:
    url = f'https://raw.githubusercontent.com/qingjian-team/qingjian/{REVISION}/{path}'
    with urllib.request.urlopen(url, timeout=90) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != SOURCES[path]:
        raise RuntimeError(f'Upstream resource hash mismatch: {path}')
    return data


def main() -> None:
    RESOURCE_DIR.mkdir(parents=True, exist_ok=True)
    dictionary = fetch('assets/lexicon/dict.tsv')
    glossary = fetch('assets/glossary/glossary-en.tsv').decode('utf-8')
    words = {line.split('\t')[0] for line in dictionary.decode('utf-8').splitlines()
             if line and not line.startswith('#')}
    gloss_lines = [line for line in glossary.splitlines() if line.split('\t')[0] in words]
    (RESOURCE_DIR / 'dict.tsv').write_bytes(dictionary)
    (RESOURCE_DIR / 'glossary-en.tsv').write_text('\n'.join(gloss_lines) + '\n', encoding='utf-8')
    print(f'Resources verified: {len(words)} words, {len(gloss_lines)} English annotations')


if __name__ == '__main__':
    main()
