-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Enable powershell as your default shell
-- vim.opt.shell = "zsh"
-- vim.opt.shellcmdflag =
-- "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
vim.cmd [[
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=

    ]]
-- Set a compatible clipboard manager
-- vim.g.clipboard = {
--   copy = {
--     ["+"] = "win32yank.exe -i --crlf",
--     ["*"] = "win32yank.exe -i --crlf",
--   },
--   paste = {
--     ["+"] = "win32yank.exe -o --lf",
--     ["*"] = "win32yank.exe -o --lf",
--   },
-- }

-- To modify your LSP keybindings use lvim.lsp.buffer_mappings.[normal|visual|insert]_mode.

lvim.builtin.terminal.open_mapping = "<c-t>"
lvim.keys.insert_mode['jj'] = "<Esc>"
-- vim.opt.tabstop = 4 -- insert 2 spaces for a tab
vim.opt.relativenumber = true -- relative line numbers
vim.opt.wrap = true           -- wrap lines
vim.opt.autoindent = true     -- autoident
lvim.colorscheme = 'default'
vim.opt.guifont = "JetBrainsMono\\ NFM:h10"

local lspconfig = require('lspconfig')

-- local csharp_ls_bin = "$HOME/git/csharp-language-server/src/CSharpLanguageServer/bin/Debug/net7.0/CSharpLanguageServer"
lspconfig.csharp_ls.setup {
  -- cmd = { csharp_ls_bin }, -- specify if you build project locally (modify csharp_ls_bin path first), otherwise download using dotnet tools & keep that like ignored
  -- specify root_dir, so lsp can find all solutions related to your workspace
  root_dir = function(startpath)
    return lspconfig.util.root_pattern("*.sln")(startpath)
        or lspconfig.util.root_pattern("*.csproj")(startpath)
        or lspconfig.util.root_pattern("*.fsproj")(startpath)
        or lspconfig.util.root_pattern(".git")(startpath)
  end,
}

-- Global mappings.
-- See :help vim.diagnostic.* for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- See :help vim.lsp.* for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- FORMATTTER
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { name = "black", filetypes = { "python" } }
}

-- lvim.plugins = {
--   {
--     "puremourning/vimspector",
--     config = function()
--       vim.cmd("let g:vimspector_enable_mappings = 'HUMAN'")
--     end,
--     vim.keymap.set('n', '<Leader>di', '<Plug>VimspectorBalloonEval'),
--     vim.keymap.set('v', '<Leader>di', '<Plug>VimspectorBalloonEval')
--   },
-- }
-- dap.adapters.coreclr = {
--   type = 'executable',
--   command = 'netcoredbg.exe',
--   args = {'--interpreter=vscode'}
-- }

lvim.builtin.dap.active = true
lvim.builtin.dap.ui.auto_open = true

-- lvim.builtin.dap.ui.

-- require("mason").setup()
lvim.plugins =
{
  "williamboman/mason.nvim",
  "mfussenegger/nvim-dap",
  "jay-babu/mason-nvim-dap.nvim",
}

require("mason-nvim-dap").setup({
  lazy = true,
  opts = {
    ensure_installed = { "coreclr" }
  },
})


vim.g.dotnet_build_project = function()
  local default_path = vim.fn.getcwd() .. '/'
  if vim.g['dotnet_last_proj_path'] ~= nil then
    default_path = vim.g['dotnet_last_proj_path']
  end
  local path = vim.fn.input('Path to your *proj file', default_path, 'file')
  vim.g['dotnet_last_proj_path'] = path
  local cmd = 'dotnet build -c Debug ' .. path .. ' > /dev/null'
  print('')
  print('Cmd to execute: ' .. cmd)
  local f = os.execute(cmd)
  if f == 0 then
    print('\nBuild: ✔️ ')
  else
    print('\nBuild: ❌ (code: ' .. f .. ')')
  end
end

vim.g.dotnet_get_dll_path = function()
  local request = function()
    return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/' .. vim.fn.expand('%:h') .. '/bin/Debug/net7.0', 'file')
  end
  if vim.g['dotnet_last_dll_path'] == nil then
    vim.g['dotnet_last_dll_path'] = request()
  else
    if vim.fn.confirm('Do you want to change the path to dll?\n' .. vim.g['dotnet_last_dll_path'], '&yes\n&no', 2) == 1 then
      vim.g['dotnet_last_dll_path'] = request()
    end
  end

  return vim.g['dotnet_last_dll_path']
end

local config = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    -- console = 'integratedTerminal',
    program = function()
      if vim.fn.confirm('Should I recompile first?', '&yes\n&no', 2) == 1 then
        vim.g.dotnet_build_project()
      end
      return vim.g.dotnet_get_dll_path()
    end,
    env = {
      ASPNETCORE_ENVIRONMENT = function()
        -- todo: request input from ui
        return "Development"
      end,
      ASPNETCORE_URLS = function()
        -- todo: request input from ui
        return "http://localhost:5050"
      end,
    },
    cwd = function()
      return vim.fn.getcwd() .. '/' .. vim.fn.expand('%:h')
    end,
    console = "integratedTerminal"
  },
}

local dap = require('dap')
dap.configurations.cs = config

dap.adapters.coreclr = {
  type = 'executable',
  command = 'netcoredbg',
  args = { '--interpreter=vscode' },
  options = {
    detached = false, -- Will put the output in the REPL. #CloseEnough
  }
}

-- dap.configurations.cs = {
--   {
--     type = "coreclr",
--     name = "launch - netcoredbg",
--     request = "launch",
--     program = function()
--       return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
--     end,

--     console = "integratedTerminal"
--   },
-- }
-- vim.api.nvim_set_keymap('n', '<C-b>', ':lua vim.g.dotnet_build_project()<CR>', { noremap = true, silent = true })

local keymap_restore = {}
dap.listeners.after['event_initialized']['me'] = function()
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    local keymaps = vim.api.nvim_buf_get_keymap(buf, 'n')
    for _, keymap in pairs(keymaps) do
      if keymap.lhs == "K" then
        table.insert(keymap_restore, keymap)
        vim.api.nvim_buf_del_keymap(buf, 'n', 'K')
      end
    end
  end
  vim.api.nvim_set_keymap(
    'n', 'K', '<Cmd>lua require("dap.ui.widgets").hover()<CR>', { silent = true })
end

dap.listeners.after['event_terminated']['me'] = function()
  for _, keymap in pairs(keymap_restore) do
    vim.api.nvim_buf_set_keymap(
      keymap.buffer,
      keymap.mode,
      keymap.lhs,
      keymap.rhs,
      { silent = keymap.silent == 1 }
    )
  end
  keymap_restore = {}
end

vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_out() end)
vim.keymap.set('n', '<S-F5>', function() require('dapui').toggle() end)
vim.keymap.set('n', '<leader>h', function() require('dap.ui.widgets').hover() end)
-- vim.api.nvim_set_keymap('n', '<M-Right>', ':vertical resize +1<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Right>', ':vertical resize +1<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Left>', ':vertical resize -1<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Down>', ':resize +1<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Up>', ':resize -1<CR>', { noremap = true, silent = true })
