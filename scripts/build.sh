#!/usr/bin/env bash
# pandoc 构建 EPUB
set -euo pipefail
cd "$(dirname "$0")/.."

mkdir -p build

mapfile -t chapters < <(ls manuscript/*.md | sort)
if [ ${#chapters[@]} -eq 0 ]; then
  echo "manuscript/ 下没有 Markdown 文件，先完成 OCR 校对。" >&2
  exit 1
fi

cover_opt=()
for c in assets/cover.jpg assets/cover.png; do
  if [ -f "$c" ]; then
    cover_opt=(--epub-cover-image="$c")
    break
  fi
done

pandoc metadata.yaml "${chapters[@]}" \
  --from markdown+footnotes+inline_notes+fenced_divs+smart \
  --to epub3 \
  --css assets/epub.css \
  --toc --toc-depth=2 \
  "${cover_opt[@]}" \
  -o "build/名作细读.epub"

echo "已生成 build/名作细读.epub"
