-- Put the first level 1 header into the title, and remove it from the document
function Pandoc(doc)
  for i, block in ipairs(doc.blocks) do
    if block.t == "Header" and block.level == 1 then
      -- Convert the header text to a string and assign to metadata title
      doc.meta.title = pandoc.MetaString(pandoc.utils.stringify(block.content))

      -- Optional: remove the original header
      table.remove(doc.blocks, i)

      break
    end
  end
  return doc
end
