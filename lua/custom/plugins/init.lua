-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'EthanJWright/vs-tasks.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      --      { 'Joakker/lua-json5', run = './install.sh' },
    },
  },
  {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      'nvim-lua/plenary.nvim',

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = 'Leo_Remote',
          path = vim.env.OBSIDIAN_VAULT,
          -- path = 'G:\\Leo_Remote',
        },
        -- {
        --   name = 'Leo_Remote',
        --   path = 'D:\\Documents\\Leo_Remote',
        -- }
      },

      -- see below for full list of options 👇
    },
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end

      vim.keymap.set('n', '<F5>', function()
        require('dap').continue()
      end, { desc = 'DAP Continue' })
      vim.keymap.set('n', '<F6>', function()
        require('dap').step_over()
      end, { desc = 'DAP Step Over' })
      vim.keymap.set('n', '<F7>', function()
        require('dap').step_into()
      end, { desc = 'DAP Step Into' })
      vim.keymap.set('n', '<F8>', function()
        require('dap').step_out()
      end, { desc = 'DAP Step Out' })
      vim.keymap.set('n', '<Leader>b', function()
        require('dap').toggle_breakpoint()
      end, { desc = 'DAP Toggle Breakpoint' })
      vim.keymap.set('n', '<Leader>B', function()
        require('dap').set_breakpoint()
      end, { desc = 'DAP Set Breakpoint' })
      vim.keymap.set('n', '<Leader>lp', function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end, { desc = 'DAP Log Point' })
      vim.keymap.set('n', '<Leader>dr', function()
        require('dap').repl.open()
      end, { desc = 'DAP Open REPL' })
      vim.keymap.set('n', '<Leader>dl', function()
        require('dap').run_last()
      end, { desc = 'DAP Run Last' })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
        require('dap.ui.widgets').hover()
      end, { desc = 'DAP Hover' })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
        require('dap.ui.widgets').preview()
      end, { desc = 'DAP Preview' })
      vim.keymap.set('n', '<Leader>df', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.frames)
      end, { desc = 'DAP Frames' })
      vim.keymap.set('n', '<Leader>ds', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes)
      end, { desc = 'DAP Scopes' })

      vim.fn.sign_define('DapBreakpoint', { text = '⛔', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '⏩', texthl = '', linehl = '', numhl = '' })
    end,
  },
  {
    'jay-babu/mason-nvim-dap.nvim',
    event = 'VeryLazy',
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    opts = {
      handlers = {},
    },
  },
  {
    'mfussenegger/nvim-dap',
  },
  { 'akinsho/toggleterm.nvim', version = '*', config = true },
  {
    'L3MON4D3/LuaSnip',
    -- follow latest release.
    version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = 'make install_jsregexp',
  },
  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'Open lazy git' },
    },
  },
  -- {
  --   'mrcjkb/rustaceanvim',
  --   version = '^5', -- Recommended
  --   lazy = false, -- This plugin is already lazy
  -- },
  -- {
  --   'GCBallesteros/NotebookNavigator.nvim',
  --   keys = {
  --     {
  --       ']h',
  --       function()
  --         require('notebook-navigator').move_cell 'd'
  --       end,
  --     },
  --     {
  --       '[h',
  --       function()
  --         require('notebook-navigator').move_cell 'u'
  --       end,
  --     },
  --     { '<leader>X', "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
  --     { '<leader>x', "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
  --   },
  --   dependencies = {
  --     'echasnovski/mini.comment',
  --     'hkupty/iron.nvim', -- repl provider
  --     -- "akinsho/toggleterm.nvim", -- alternative repl provider
  --     -- "benlubas/molten-nvim", -- alternative repl provider
  --     'anuvyklack/hydra.nvim',
  --   },
  --   event = 'VeryLazy',
  --   config = function()
  --     local nn = require 'notebook-navigator'
  --     nn.setup { activate_hydra_keys = '<leader>h' }
  --   end,
  -- },
  {
    'Vigemus/iron.nvim',
    config = function()
      require('iron.core').setup {
        config = {
          scratch_repl = true,
          repl_definition = {
            python = require('iron.fts.python').ipython,
            -- python = {
            --   command = { 'pypy' },
            --   format = require('iron.fts.common').bracketed_paste_python,
            -- },
          },
          ignore_blank_lines = true,
          repl_open_cmd = 'vertical botright 80 split',
        },
      }
    end,
  },
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    dependencies = { 'GCBallesteros/NotebookNavigator.nvim' },
    opts = function()
      local nn = require 'notebook-navigator'

      local opts = { custom_textobjects = { h = nn.miniai_spec } }
      return opts
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
