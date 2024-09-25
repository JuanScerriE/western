local wezterm = require('wezterm')

local function is_found(str, pattern)
  return string.find(str, pattern) ~= nil
end

local function platform()
  local is_win = is_found(wezterm.target_triple, 'windows')
  local is_linux = is_found(wezterm.target_triple, 'linux')
  local is_mac = is_found(wezterm.target_triple, 'apple')

  local os = is_win and 'windows' or is_linux and 'linux' or is_mac and 'mac' or 'unknown'

  return {
    os = os,
    is_win = is_win,
    is_linux = is_linux,
    is_mac = is_mac,
  }
end

local os = platform()

local mod = {}

if os.is_mac then
  mod.SUPER = 'SUPER'
  mod.SUPER_REV = 'SUPER|CTRL'
elseif os.is_linux then
  mod.SUPER = 'ALT'
  mod.SUPER_REV = 'ALT|CTRL'
end

local act = wezterm.action

local config = {
  -- gpu
  animation_fps = 60,
  max_fps = 60,
  front_end = 'WebGpu',
  webgpu_power_preference = 'HighPerformance',

  -- appearance
  font = wezterm.font('Menlo'),
  force_reverse_video_cursor = true,
  use_fancy_tab_bar = false,
  color_scheme = 'AdventureTime',

  -- key bindings
  keys = {
    -- misc/useful --
    { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
    { key = 'F12', mods = 'NONE', action = act.ShowDebugOverlay },

    -- command palette
    { key = 'p', mods = mod.SUPER, action = act.ActivateCommandPalette },

    -- cursor movement
    { key = 'LeftArrow', mods = mod.SUPER, action = act.SendString('\x1bOH') },
    { key = 'RightArrow', mods = mod.SUPER, action = act.SendString('\x1bOF') },
    { key = 'Backspace', mods = mod.SUPER, action = act.SendString('\x15') },

    -- copy/paste
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },

    -- tabs: spawn + close
    { key = 't', mods = mod.SUPER, action = act.SpawnTab('DefaultDomain') },
    { key = 'w', mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

    -- tabs: navigation
    { key = '[', mods = mod.SUPER, action = act.ActivateTabRelative(-1) },
    { key = ']', mods = mod.SUPER, action = act.ActivateTabRelative(1) },
    { key = '[', mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
    { key = ']', mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

    -- spawn windows
    { key = 'n', mods = mod.SUPER, action = act.SpawnWindow },

    -- panes: split panes
    {
      key = [[\]],
      mods = mod.SUPER_REV,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },
    {
      key = [[\]],
      mods = mod.SUPER,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },

    -- panes: zoom + close pane
    { key = 'Enter', mods = mod.SUPER, action = act.TogglePaneZoomState },
    { key = 'w', mods = mod.SUPER, action = act.CloseCurrentPane({ confirm = false }) },

    -- panes: navigation
    { key = 'k', mods = mod.SUPER, action = act.ActivatePaneDirection('Up') },
    { key = 'j', mods = mod.SUPER, action = act.ActivatePaneDirection('Down') },
    { key = 'h', mods = mod.SUPER, action = act.ActivatePaneDirection('Left') },
    { key = 'l', mods = mod.SUPER, action = act.ActivatePaneDirection('Right') },
    {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
    },

    -- control font
    { key = '-', mods = mod.SUPER, action = act.DecreaseFontSize },
    { key = '+', mods = mod.SUPER, action = act.IncreaseFontSize },
    { key = '=', mods = mod.SUPER, action = act.ResetFontSize },
  },

  -- mouse bindings
  mouse_bindings = {
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
    },
  },

  -- disable default bindings
  disable_default_key_bindings = true,
}

return config
