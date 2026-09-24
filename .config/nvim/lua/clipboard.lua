-- Local sessions keep Neovim's native clipboard provider.
if not (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) then
  return
end

-- Reach the connecting terminal's clipboard instead of the remote desktop's.
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = osc52.paste("+"),
    ["*"] = osc52.paste("*"),
  },
}
