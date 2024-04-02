function Header(el)
  -- Create the anchor element with the section ID
  local anchor = pandoc.RawInline('html', '<a class="anchor" href="#' .. el.identifier .. '"></a>')
  
  -- Insert the anchor before the header's content
  table.insert(el.content, 1, anchor)
  
  return el
end

return {{Header = Header}}

