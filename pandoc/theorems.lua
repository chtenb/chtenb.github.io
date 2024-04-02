-- Define a global counter for definitions
local definition_counter = 0

function Div(el)
  -- Check if the Div has the class 'Definition'
  if el.classes:includes("Definition") then
    definition_counter = definition_counter + 1
    
    -- Assuming the first block inside the Div is a Header with the category name
    local header = el.content[1]
    if header and header.t == "Header" then
      local category = pandoc.utils.stringify(header.content)
      
      -- Create the new header text
      local new_header_text = "Definition " .. definition_counter .. ". (" .. category .. ")"
      
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

return {{Div = Div}}
