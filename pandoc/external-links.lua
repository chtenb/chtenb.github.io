function Link(link)
  local href = link.target

  -- Check if it's an external link
  if href:match("^https?://") then
    -- Add a CSS class
    link.attributes["class"] = (link.attributes["class"] or "") .. " external"

    -- Open external links in a new tab
    link.attributes["target"] = "_blank"
  end

  return link
end
