-- toc-generator.lua
-- This Lua filter for Pandoc generates a table of contents (TOC) based on document headers.

local toc = {} -- Table to hold the TOC entries
local max_level = 4 -- Adjust to set the deepest header level included in the TOC

-- Function to collect headers into the TOC
function Header(elem)
  if elem.level <= max_level then
    -- Create a link for the header. The content of a link should be a list of inline elements.
    local link = pandoc.Link(elem.content, '#' .. elem.identifier)
    -- Insert the link as an item (wrapped in a list of inlines) into the TOC
    table.insert(toc, pandoc.Plain({link}))
  end
  return elem
end

-- Function to insert the TOC at the beginning of the document
function Pandoc(doc)
  -- Only proceed if the TOC is not empty
  if #toc > 0 then
    -- Convert the TOC entries into a BulletList
    local tocList = pandoc.BulletList(toc)
    -- Create a block for the TOC title
    table.insert(doc.blocks, 2, tocList)
  end
  return pandoc.Pandoc(doc.blocks, doc.meta)
end

return {
  {Header = Header, Pandoc = Pandoc}
}
