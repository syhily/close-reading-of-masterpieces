-- 诗块排版辅助：
-- 1) 行块（| 开头）里的空行（裸 |）视为诗节分界，拆成多个行块——
--    裸行块拆分后靠各自的上下 margin 形成节间距（古诗中间分段）；
-- 2) ::: {.poem} 的内容包两层：
--    内层每个诗节包块级 div.stanza —— 强制独占一行、节间留白；
--    全部诗节再包进一个 div.poem-inner（CSS 设为 inline-block）—— 收缩到
--    最宽诗节的宽度后整体居中，所有诗节共享同一条左边缘（节内左对齐）。
-- 不用 flex（Clearview 支持不佳）、不用 display:table（Clearview 会强制套自带字体覆盖楷体）。
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
