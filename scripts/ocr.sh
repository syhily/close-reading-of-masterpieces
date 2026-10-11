#!/usr/bin/env bash
# MinerU 多模式 OCR：
#   pipeline 模式 —— 无幻觉，作为校对基准
#   vlm 模式      —— 复杂版式精度更高，用于交叉比对
# 两种结果存入 ocr/（不入库），比对与校对流程见 docs/workflow.md。
set -euo pipefail
cd "$(dirname "$0")/.."

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

echo "==> MinerU pipeline 模式（基准）"
mineru-open-api extract "$PDF" -o ocr/pipeline -f md --model pipeline --language ch

echo "==> MinerU vlm 模式（交叉比对）"
mineru-open-api extract "$PDF" -o ocr/vlm -f md --model vlm --language ch

echo "完成。结果在 ocr/pipeline/ 与 ocr/vlm/，下一步见 docs/workflow.md。"
