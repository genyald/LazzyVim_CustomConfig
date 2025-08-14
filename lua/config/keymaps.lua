-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
--
-- Equivalentes a los mappings por defecto de NVChad para LazyVim
-- Implementa fallbacks seguros si las utilidades NVChad no están instaladas.

local map = vim.keymap.set

-- ====================
-- Insert mode nav (NVChad)
-- ====================
map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

-- ====================
-- Misc general
-- ====================
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

-- ====================
-- NvimTree
-- ====================
-- map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
-- map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })
map("n", "<C-n>", "<cmd>Neotree toggle<CR>", { desc = "neo-tree toggle window" })
map("n", "<leader>e", "<cmd>Neotree reveal<CR>", { desc = "neo-tree reveal current file / focus" })

-- ====================
-- Telescope
-- ====================
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>pt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- Depuración estilo VSCode
map("n", "<F5>", function()
  require("dap").continue()
end, { desc = "DAP: Iniciar / Continuar" })
map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "DAP: Step Over" })
map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "DAP: Step Into" })
map("n", "<S-F11>", function()
  require("dap").step_out()
end, { desc = "DAP: Step Out" })
map("n", "<S-F5>", function()
  require("dap").terminate()
end, { desc = "DAP: Detener" })
map("n", "<C-S-F5>", function()
  require("dap").restart()
end, { desc = "DAP: Reiniciar" })

map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end, { desc = "DAP: Alternar Breakpoint" })
map("n", "<C-F9>", function()
  require("dap").set_breakpoint(vim.fn.input("Condición: "))
end, { desc = "DAP: Breakpoint condicional" })

map("n", "<C-S-e>", function()
  require("dapui").eval()
end, { desc = "DAP: Evaluar expresión" })

-- ====================
-- WhichKey helpers
-- ====================
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

-- ====================
-- Tab / quick buffer helpers used in NVChad
-- ====================
-- Keep existing LazyVim buffer nav but add NVChad-like bindings
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- ====================
-- Small niceties from NVChad
-- ====================
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true }) -- re-apply (harmless)
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new (nvchad equiv)" })

-- Forzar Ctrl-k en modo insert al estilo NVChad, anulando mappings buffer-local de blink.cmp u otros.
local function set_insert_ctrl_k(buf)
  -- intenta eliminar cualquier mapping 'i' tanto global como buffer-local
  pcall(vim.keymap.del, "i", "<C-k>") -- global
  pcall(vim.keymap.del, "i", "<C-k>", { buffer = buf }) -- buffer-local

  -- reasignar buffer-localmente el comportamiento NVChad
  local ok, err = pcall(function()
    vim.keymap.set("i", "<C-k>", "<C-O>k", {
      desc = "move up (insert mode) - NVChad override",
      remap = true,
      buffer = buf,
    })
  end)
  if not ok then
    vim.notify("Error al setear <C-k> buffer-local: " .. tostring(err), vim.log.levels.WARN)
  end
end

-- Intenta fijar el mapping ahora para el buffer actual (por si ya estás dentro)
pcall(function()
  set_insert_ctrl_k(0)
end)

-- Reaplica cuando entran en modo Insert (por si el plugin asigna en InsertEnter)
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    set_insert_ctrl_k(bufnr)
  end,
})

vim.keymap.set("t", "<Esc>", function()
  local bufname = vim.api.nvim_buf_get_name(0)

  -- Verifica si es un buffer de toggleterm
  if bufname:match("toggleterm") then
    local winid = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(winid)

    -- Si es flotante (config.relative ~= "")
    if config.relative ~= "" then
      -- Salir de terminal mode y cerrar
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
      vim.cmd("ToggleTerm")
      return
    end
  end

  -- Si no es toggleterm flotante → solo salir de terminal mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
end, { noremap = true, silent = true })
-- End of file
--
