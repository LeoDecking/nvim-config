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
}
