local utils = require("refractalize.utils")

local function google(search_term)
  local escaped_search_term = search_term:gsub("\n", "\r\n"):gsub("([^%w])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)

  local open_command = vim.fn.has("mac") == 1 and "open" or "xdg-open"

  vim.fn.system({ open_command, "https://www.google.com/search?q=" .. escaped_search_term })
end

local function google_visual_selection(additional_query)
  local visual_selection = utils.get_visual_lines()
  local visual_query = (visual_selection and vim.fn.join(visual_selection, " "))
  local query = vim.fn.join(
    vim.tbl_filter(function(i)
      return i
    end, { visual_query, additional_query }),
    " "
  )
  google(query)
end

local function setup()
  vim.api.nvim_create_user_command("Google", function(opts)
    if opts.range > 0 then
      google_visual_selection(opts.args)
    else
      google(opts.args)
    end
  end, { nargs = "*", range = true })
end

return {
  google = google,
  google_visual_selection = google_visual_selection,
  setup = setup,
}
