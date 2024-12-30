-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Enable powershell as your default shell
-- vim.opt.shell = "zsh"
-- vim.opt.shellcmdflag =
-- "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.cmd [[
    let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=

    ]]

lvim.builtin.terminal.open_mapping = "<c-t>"
lvim.keys.insert_mode['jj'] = "<Esc>"
vim.opt.tabstop = 4           -- insert 2 spaces for a tab
vim.opt.relativenumber = true -- relative line numbers
vim.opt.wrap = true           -- wrap lines
vim.opt.autoindent = true     -- autoident
lvim.colorscheme = 'tokyonight-night'
lvim.builtin.lualine.style = "lvim"
lvim.lsp.automatic_installation = true -- Tự động cài đặt LSP
lvim.lsp.installer.setup.automatic_installation = true
vim.opt.guifont = "JetBrainsMono\\ NFM:h10"
vim.opt.termguicolors = true

-- LSP
local lspconfig = require('lspconfig')
lspconfig.csharp_ls.setup {
  root_dir = function(startpath)
    return lspconfig.util.root_pattern("*.sln")(startpath)
        or lspconfig.util.root_pattern("*.csproj")(startpath)
        or lspconfig.util.root_pattern("*.fsproj")(startpath)
        or lspconfig.util.root_pattern(".git")(startpath)
  end,
}

lspconfig.lemminx.setup {
  cmd = { "lemminx" },
  filetypes = { "xml", "xsd", "xsl", "xslt", "svg", "props" },
  single_file_support = true
}


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

lvim.builtin.dap.active = true
lvim.builtin.dap.ui.auto_open = true
lvim.transparent_window = true
-- Pluging: unblevable/quick-scope
-- vim.g.qs_highlight_on_keys = {'f', 'F'}
-- lvim.builtin.dap.ui.

-- require("mason").setup()
lvim.plugins =
{
  "williamboman/mason.nvim",
  "folke/which-key.nvim",
  "kyazdani42/nvim-web-devicons",
  "kyazdani42/nvim-tree.lua",
  "mfussenegger/nvim-dap",
  "folke/tokyonight.nvim",
  "nixprime/cpsm",
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "Issafalcon/neotest-dotnet",
    }
  },
  "unblevable/quick-scope",
  "romgrk/fzy-lua-native",
  "Cliffback/netcoredbg-macOS-arm64.nvim",
  dependencies = { "mfussenegger/nvim-dap" },
  "jay-babu/mason-nvim-dap.nvim",
  {
    "gelguy/wilder.nvim",
    config = function()
      local wilder = require('wilder')
      wilder.setup({ modes = { ':', '/', '?' } })

      wilder.set_option('pipeline', {
        wilder.branch(
        -- brew install fd
          wilder.python_file_finder_pipeline({
            file_command = function(ctx, arg)
              if string.find(arg, '.') ~= nil then
                return { 'fd', '-tf', '-H' }
              else
                return { 'fd', '-tf' }
              end
            end,
            dir_command = { 'fd', '-td' },
            -- filters = { 'cpsm_filter' },
          }),
          wilder.substitute_pipeline({
            pipeline = wilder.python_search_pipeline({
              skip_cmdtype_check = 1,
              pattern = wilder.python_fuzzy_pattern({
                start_at_boundary = 0,
              }),
            }),
          }),
          wilder.cmdline_pipeline({
            fuzzy = 2,
            fuzzy_filter = wilder.lua_fzy_filter(),
          }),
          {
            wilder.check(function(ctx, x) return x == '' end),
            wilder.history(),
          },
          wilder.python_search_pipeline({
            pattern = wilder.python_fuzzy_pattern({
              start_at_boundary = 0,
            }),
          })
        ),
      })

      local highlighters = {
        wilder.pcre2_highlighter(),
        wilder.basic_highlighter(),
      }

      wilder.set_option('renderer', wilder.renderer_mux({
        [':'] = wilder.popupmenu_renderer({
          highlighter = highlighters,
        }),
        ['/'] = wilder.wildmenu_renderer({
          highlighter = highlighters,
        }),
      }))
    end,
  }
}

vim.g.nvim_tree_icons = {
  default = '',
  symlink = '',
  git = {
    unstaged = "",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "",
    modified = '✥',
  },
  folder = {
    default = "",
    open = "",
    empty = "",
    empty_open = "",
    symlink = ""
  }
}

require("neotest").setup({
  adapters = {
    require("neotest-dotnet")({
      discovery_root = "project" -- Default
    })
  }
})

local wk = require("which-key")
wk.register({
  t = {
    name = "Test",                          -- Nhóm phím tắt cho kiểm thử
    n = { ":Neotest run<CR>", "Run Test" }, -- Chạy bài kiểm thử
    f = {
      function()
        print(vim.fn.expand('%:p'))
        require('neotest').run.run(vim.fn.expand('%:p'))
      end,
      "Run File Test"
    },
    t = {
      function()
        require('neotest').summary.toggle()
      end,
      "Toggle Neotest Summary"
    },                                                                                -- Bật/tắt summary của Neotest
    s = { ":Neotest run --suite<CR>", "Run Suite Tests" },                            -- Chạy bài kiểm thử trong suite
    l = { ":Neotest run --last<CR>", "Run Last Test" },                               -- Chạy bài kiểm thử cuối cùng
    o = { ":Neotest output<CR>", "Open Test Output" },                                -- Mở đầu ra kiểm thử
    d = { ":lua require('neotest').run.run({strategy = 'dap'})<CR>", "Debug Tests" }, -- Chạy bài kiểm thử trong file
    a = { ":lua require('neotest').run.run(vim.fn.getcwd())<CR>", "Run all test" },   -- Chạy bài kiểm thử tất cả các bài test
  },
}, { prefix = "<leader>" })                                                           -- Đặt prefix cho các phím tắt


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
    program = function()
      if vim.fn.confirm('Should I recompile first?', '&yes\n&no', 2) == 1 then
        vim.g.dotnet_build_project()
      end
      return vim.g.dotnet_get_dll_path()
    end,
    env = {
      ASPNETCORE_ENVIRONMENT = function()
        -- todo: request input from ui
        return "development"
      end,
      ASPNETCORE_URLS = function()
        -- todo: request input from ui
        return "http://localhost:5000"
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
  command =
  '/Users/phamtienhung/.local/share/lunarvim/site/pack/lazy/opt/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg',
  args = { '--interpreter=vscode' },
  options = {
    detached = false, -- Will put the output in the REPL. #CloseEnough
  }
}

dap.adapters.netcoredbg = {
  type = 'executable',
  command =
  '/Users/phamtienhung/.local/share/lunarvim/site/pack/lazy/opt/netcoredbg-macOS-arm64.nvim/netcoredbg/netcoredbg',
  args = { '--interpreter=vscode' }
}

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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-float",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close!<CR>", { noremap = true, silent = true })
  end
})

-- Global mappings.
-- See :help vim.diagnostic.* for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Debug mapping
vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_out() end)
vim.keymap.set('n', '<leader>h', function() require('dap.ui.widgets').hover() end)

-- Window mapping
vim.api.nvim_set_keymap('n', '<C-M-Right>', ':vertical resize +3<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Left>', ':vertical resize -3<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Down>', ':resize +3<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-M-Up>', ':resize -3<CR>', { noremap = true, silent = true })

-- Cấu hình phím tắt cho Neotest sử dụng vim.api
-- local opts = { noremap = true, silent = true }
-- vim.api.nvim_set_keymap("n", "<leader>tn", ":Neotest run<CR>", opts)         -- Chạy bài kiểm thử
-- vim.api.nvim_set_keymap("n", "<leader>tf", ":Neotest run --file<CR>", opts)  -- Chạy bài kiểm thử trong file hiện tại
-- vim.api.nvim_set_keymap("n", "<leader>ts", ":Neotest run --suite<CR>", opts) -- Chạy bài kiểm thử trong suite
-- vim.api.nvim_set_keymap("n", "<leader>tl", ":Neotest run --last<CR>", opts)  -- Chạy bài kiểm thử cuối cùng
-- vim.api.nvim_set_keymap("n", "<leader>to", ":Neotest output<CR>", opts)      -- Mở đầu ra kiểm thử
--

-- empty setup using defaults
require("nvim-tree").setup()
