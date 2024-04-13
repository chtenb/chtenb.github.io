-- Define a global counter
local counter = 0

-- A set of categories to handle
local categories = {
  Definition = true,
  Lemma = true,
  Theorem = true,
  Example = true
}

function Div(el)
  -- Check if the Div has any of the categories as a class
  for category, _ in pairs(categories) do
    if el.classes:includes(category) then
      counter = counter + 1
      
      -- Assuming the first block inside the Div is a Header with the category name
      local header = el.content[1]
      if header and header.t == "Header" then
        local category_name = pandoc.utils.stringify(header.content)
        
        -- Create the new header text
        local new_header_text = category .. " " .. counter .. ". (" .. category_name .. ")"
        
        -- Replace the existing header content
        header.content = pandoc.List:new{pandoc.Str(new_header_text)}
        
        -- Adjust the header level to 4
        header.level = 4
        
        -- Replace the original header in the Div content
        el.content[1] = header
      end
      
      return el
    end
  end
end

return {{Div = Div}}

