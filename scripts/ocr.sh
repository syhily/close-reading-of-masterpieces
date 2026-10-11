#!/usr/bin/env bash
# MinerU 多模式 OCR：
#   pipeline 模式 —— 无幻觉，作为校对基准
#   vlm 模式      —— 复杂版式精度更高，用于交叉比对
# 两种结果存入 ocr/（不入库），比对与校对流程见 docs/workflow.md。
#
# extract 模式单次上限 200 页，本脚本按 CHUNK 页自动分片，
# 每片输出 ocr/<模式>/part-NNN.md，校对时按序合并使用。
set -euo pipefail
cd "$(dirname "$0")/.."

CHUNK=200

PDF="${1:-source/名作细读：微观分析个案研究.pdf}"
if [ ! -f "$PDF" ]; then
  # source/ 下只有一个 PDF 时自动取用
  mapfile -t pdfs < <(ls source/*.pdf 2>/dev/null || true)
  if [ ${#pdfs[@]} -eq 1 ]; then
    PDF="${pdfs[0]}"
  else
    echo "未找到 PDF。请将原书放入 source/，或执行：$0 <pdf路径>" >&2
    exit 1
  fi
fi

# 获取总页数（macOS 用 mdls，Linux 用 pdfinfo）
pages=$(mdls -name kMDItemNumberOfPages -raw "$PDF" 2>/dev/null || true)
if ! [[ "$pages" =~ ^[0-9]+$ ]]; then
  pages=$(pdfinfo "$PDF" 2>/dev/null | awk '/^Pages:/ {print $2}')
fi
if ! [[ "${pages:-}" =~ ^[0-9]+$ ]]; then
  echo "无法获取 PDF 页数，请安装 pdfinfo（poppler）。" >&2
  exit 1
fi
echo "PDF：$PDF（共 $pages 页，每片 $CHUNK 页）"

for model in pipeline vlm; do
  echo "==> MinerU $model 模式"
  start=1
  part=1
  while [ "$start" -le "$pages" ]; do
    end=$((start + CHUNK - 1))
    [ "$end" -gt "$pages" ] && end=$pages
    out=$(printf "ocr/%s/part-%03d.md" "$model" "$part")
    if [ -s "$out" ]; then
      echo "    跳过已存在的 $out（删除后可重跑）"
    else
      echo "    识别第 $start-$end 页 -> $out"
      mkdir -p "ocr/$model"
      mineru-open-api extract "$PDF" -o "$out" -f md \
        --model "$model" --language ch --pages "$start-$end"
    fi
    start=$((end + 1))
    part=$((part + 1))
  done
done

echo "完成。结果在 ocr/pipeline/ 与 ocr/vlm/，下一步见 docs/workflow.md。"
