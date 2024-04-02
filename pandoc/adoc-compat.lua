-- file: wrap-in-div.lua

-- This function will be called at the end of the document conversion process.
-- It wraps the entire document in a <div id="content">.
function Pandoc(doc)
  -- Create a new Div block with the id "content".
  local wrapped_content = pandoc.Div(doc.blocks, {id = "content"})

  -- Return a new Pandoc document with the wrapped content.
  return pandoc.Pandoc(wrapped_content, doc.meta)
end
