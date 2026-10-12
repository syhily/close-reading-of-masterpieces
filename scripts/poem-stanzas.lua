-- 把 ::: {.poem} 的内容包两层：
--   内层每个诗节（LineBlock）包块级 div.stanza —— 强制独占一行、节间留白；
--   全部诗节再包进一个 div.poem-inner（CSS 设为 inline-block）—— 收缩到
--   最宽诗节的宽度后整体居中，所有诗节共享同一条左边缘（节内左对齐）。
-- 不用 flex（Clearview 支持不佳）、不用 display:table（Clearview 会强制套自带字体覆盖楷体）。
function Div(el)
  if not el.classes:includes("poem") then
    return nil
  end
  local inner = {}
  for _, b in ipairs(el.content) do
    if b.t == "LineBlock" then
      table.insert(inner, pandoc.Div({ b }, pandoc.Attr("", { "stanza" })))
    else
      table.insert(inner, b)
    end
  end
  el.content = { pandoc.Div(inner, pandoc.Attr("", { "poem-inner" })) }
  return el
end
