#!/usr/bin/env python3
"""打包已编译的 iPhone App，保留扩展；不生成或伪造签名。"""
from pathlib import Path
import zipfile
root = Path(__file__).resolve().parent.parent
payload = root / 'build/package/Payload'
assert (payload / 'PersonalKeyboard.app/PlugIns/PersonalKeyboardExtension.appex').is_dir(), '键盘扩展缺失'
with zipfile.ZipFile(root / 'build/PersonalKeyboard-unsigned.ipa', 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(payload.rglob('*')):
        if path.is_file():
            archive.write(path, path.relative_to(payload.parent))
