function Link(link)
  local href = link.target

  -- Check if it's an external link
  if href:match("^https?://") then
    -- Add or modify the 'target' attribute
    link.attributes["target"] = "_blank"
  end

  return link
end
