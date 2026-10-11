# 名作细读（Close Reading of Masterpieces）

将孙绍振《名作细读：微观分析个案研究》PDF 制作为 EPUB 电纸书的项目。

## 制作流程

```
PDF ──MinerU 多模式 OCR──▶ ocr/（原始识别结果，不入库）
        │  交叉比对、人工校对（见 docs/workflow.md）
        ▼
manuscript/（校对后的 Markdown，Git 管理）
        │  pandoc
        ▼
build/名作细读.epub
```

本书为文学评论类图书，特点是**脚注较多**、**正文穿插选文**（作品原文引用）。
Markdown 约定见 [docs/workflow.md](docs/workflow.md)：

- 脚注统一使用 pandoc 行内脚注 `^[脚注内容]`，避免编号漂移；
- 选文统一使用块引用 `> ` 或 `::: {.xuanwen}` 容器，EPUB 中有独立样式。

## 目录结构

```
├── metadata.yaml          # pandoc 元数据（书名、作者、语言等）
├── Makefile               # make build / make ocr / make clean
├── assets/
│   ├── epub.css           # EPUB 排版样式（中文文学评论类）
│   └── cover.jpg          # 封面（可选，存在即自动嵌入）
├── manuscript/            # 校对后的正文 Markdown（按章节一文件，Git 管理）
├── ocr/                   # MinerU 各模式识别结果（.gitignore，不入库）
│   ├── pipeline/          # pipeline 模式：无幻觉，作为基准
│   └── vlm/               # vlm 模式：复杂版式精度更高
├── scripts/
│   ├── ocr.sh             # MinerU 多模式 OCR
│   └── build.sh           # pandoc 构建 EPUB
├── source/                # 原始 PDF（.gitignore，不入库）
└── docs/workflow.md       # OCR 校对与 Markdown 规范
```

## 使用

### 1. 准备

```bash
# 依赖：pandoc、mineru-open-api（npm install -g mineru-open-api）
mineru-open-api auth   # extract 模式需要 token（https://mineru.net/apiManage/token）
cp "名作细读：微观分析个案研究.pdf" source/
```

### 2. OCR（多模式交叉识别）

```bash
make ocr        # 依次以 pipeline / vlm 两种模式识别，结果写入 ocr/
```

随后按 [docs/workflow.md](docs/workflow.md) 比对两个模式的结果，逐章校对为
`manuscript/` 下的 Markdown。

### 3. 构建 EPUB

```bash
make build      # 输出 build/名作细读.epub
```

## GitHub Action

推送到 `main` 或打 `v*` 标签时自动构建 EPUB：

- 普通推送：EPUB 作为构建产物（artifact）上传；
- 标签推送：自动创建 GitHub Release 并附带 EPUB。
