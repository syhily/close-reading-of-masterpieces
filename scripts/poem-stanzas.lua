-- 诗块排版辅助：
-- 1) 行块（| 开头）里的空行（裸 |）视为诗节分界，拆成多个行块——
--    裸行块拆分后靠各自的上下 margin 形成节间距（古诗中间分段）；
-- 2) ::: {.poem} 的内容包两层：
--    内层每个诗节包块级 div.stanza —— 强制独占一行、节间留白；
--    全部诗节再包进一个 div.poem-inner（普通块级容器）。
--    居中由 CSS 逐行 text-align:center 实现，不用 inline-block 收缩居中——
--    Boox（NeoReader）的 shrink-to-fit 会把诗块压成一个字宽（一行一字），
--    且无视 white-space: nowrap；.poem 只用于每行字数相同的律诗/绝句，
--    各行居中与收缩居中视觉相同（行长不一的词/新诗退化为逐行居中）。
-- 3) EPUB 输出时把行块整体序列化成单行原始 HTML（<br /> 之后不留换行）：
--    pandoc 默认在 <br /> 后输出换行符，Boox 等阅读器会把换行折叠出的空格
--    渲染在行首（或对 <br /> 之后的行套首行缩进），导致除第一行外所有诗行
--    统一向右偏移；单行输出行首无任何空白，各阅读器表现一致。
local function split_line_block(lb)
  local parts, cur = {}, {}
  for _, line in ipairs(lb.content) do
    if #line == 0 then
      if #cur > 0 then
        table.insert(parts, cur)
        cur = {}
      end
    else
      table.insert(cur, line)
    end
  end
  if #cur > 0 then
    table.insert(parts, cur)
  end
  return parts
end

function Div(el)
  if not el.classes:includes("poem") then
    return nil
  end
  local inner = {}
  for _, b in ipairs(el.content) do
    if b.t == "LineBlock" then
      for _, part in ipairs(split_line_block(b)) do
        table.insert(inner, pandoc.Div({ pandoc.LineBlock(part) }, pandoc.Attr("", { "stanza" })))
      end
    else
      table.insert(inner, b)
    end
  end
  el.content = { pandoc.Div(inner, pandoc.Attr("", { "poem-inner" })) }
  return el
end

function LineBlock(el)
  local parts = split_line_block(el)
  if #parts <= 1 then
    return nil
  end
  local out = {}
  for _, part in ipairs(parts) do
    table.insert(out, pandoc.LineBlock(part))
  end
  return out
end

local function line_block_to_raw(lb)
  local parts = {}
  for i, line in ipairs(lb.content) do
    if i > 1 then
      table.insert(parts, "<br />")
    end
    local html = pandoc.write(pandoc.Pandoc({ pandoc.Plain(line) }), "html", { wrap_text = "wrap-none" })
    table.insert(parts, (html:gsub("^%s+", ""):gsub("%s+$", "")))
  end
  return pandoc.RawBlock("html", '<div class="line-block">' .. table.concat(parts) .. "</div>")
end

function Pandoc(doc)
  if not FORMAT:match("epub") then
    return nil
  end
  return doc:walk({
    LineBlock = function(lb)
      return line_block_to_raw(lb)
    end,
  })
end
