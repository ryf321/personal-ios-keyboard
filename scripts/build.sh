#!/bin/bash
# 在 Mac 或 GitHub 的标准 macOS runner 上生成未签名安装包。
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:-device}"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS 编译需要 macOS/Xcode。Windows 请使用附带的 GitHub Actions 流程。" >&2
  exit 1
fi
export PATH="$HOME/.cargo/bin:$PATH"
command -v cargo >/dev/null || { echo "请先安装 Rust: https://rustup.rs" >&2; exit 1; }
command -v xcodegen >/dev/null || { echo "请先运行 brew install xcodegen" >&2; exit 1; }
xcodebuild -version
if [[ "$mode" == "simulator" ]]; then
  if [[ "$(uname -m)" == "arm64" ]]; then
    target="aarch64-apple-ios-sim"
    architecture="arm64"
  else
    target="x86_64-apple-ios"
    architecture="x86_64"
  fi
  destination="generic/platform=iOS Simulator"
else
  target="aarch64-apple-ios"
  architecture="arm64"
  destination="generic/platform=iOS"
fi
rustup target add "$target"
if [[ ! -f ios/Resources/dict.tsv || ! -f ios/Resources/glossary-en.tsv ]]; then
  python3 scripts/prepare_resources.py
fi
cargo run --locked -p qingjian-ios --bin pack -- ios/Resources
cargo build --locked --release -p qingjian-ios --lib --target "$target"
mkdir -p ios/Libraries
cp "target/$target/release/libqingjian_ios.a" ios/Libraries/
xcodegen generate --spec ios/project.yml
xcodebuild -project ios/PersonalKeyboard.xcodeproj -scheme PersonalKeyboard \
  -configuration Release -destination "$destination" -derivedDataPath "build/$mode" \
  ARCHS="$architecture" ONLY_ACTIVE_ARCH=YES \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
if [[ "$mode" == "device" ]]; then
  mkdir -p build/package/Payload
  cp -R build/device/Build/Products/Release-iphoneos/PersonalKeyboard.app build/package/Payload/
  python3 scripts/package.py
  echo "完成：build/PersonalKeyboard-unsigned.ipa（需要在 Windows 用自己的账号签名后安装）"
fi
