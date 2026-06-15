local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Appearance
config.color_scheme = "Tokyo Night"

-- Hide tab bar since you're using niri for window management
config.enable_tab_bar = false

-- Optional but recommended with no tab bar
config.window_decorations = "NONE" -- remove title bar too, niri handles it
-- or "TITLE" if you want to keep the title bar

-- Padding (personal taste)
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- config.disable_default_key_bindings = true

config.keys = {
  {
    key = "t",
    mods = "SUPER|SHIFT",
    action = wezterm.action.SpawnCommandInNewWindow({ args = { wezterm.home_dir .. "/.local/bin/dev-container" } }),
  },
  {
    key = "+",
    mods = "CTRL",
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = "-",
    mods = "CTRL",
    action = wezterm.action.DecreaseFontSize,
  },

  {
    key = "r",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ReloadConfiguration,
  },

  -- Copy selection if any, otherwise pass Ctrl-C to process
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ""
      if has_selection then
        window:perform_action(wezterm.action.CopyTo("Clipboard"), pane)
      else
        window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
      end
    end),
  },

  -- Paste using OSC 52 bracketed paste
  {
    key = "v",
    mods = "CTRL",
    action = wezterm.action.PasteFrom("Clipboard"),
  },
}

return config
