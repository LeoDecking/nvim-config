local M = {}

-- 0 = global errors (quickfix), 1 = local errors (location), 2 = all local (location), 3 = closed
M.diag_state = 0

-- Get diagnostics for a state
function M.get_diags_for_state(state)
  if state == 0 then
    return vim.diagnostic.get(nil, { severity = vim.diagnostic.severity.ERROR }) -- global errors
  elseif state == 1 then
    return vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) -- local errors
  elseif state == 2 then
    return vim.diagnostic.get(0, {}) -- all local
  else
    return {}
  end
end

-- Show command-line message with counts
function M.show_status_message()
  local global = #M.get_diags_for_state(0)
  local local_err = #M.get_diags_for_state(1)
  local all_local = #M.get_diags_for_state(2)
  if global == 0 and local_err == 0 and all_local == 0 then
    return
  end
  local msg = string.format('🌍 %d | 🔴 %d | 🟠 %d', global, local_err, all_local)
  vim.api.nvim_echo({ { msg, 'None' } }, false, {})
end

-- Update the list for a given state
function M.update_diag_list(state)
  local diags = M.get_diags_for_state(state)

  if #diags == 0 then
    -- Close the list if there are no diagnostics for this state
    if state == 0 then
      vim.cmd 'cclose'
    else
      vim.cmd 'lclose'
    end
  else
    vim.cmd 'lclose'
    vim.cmd 'cclose'
    if state == 0 then
      vim.fn.setqflist({}, ' ', {
        title = 'Diagnostics (Global Errors)',
        items = vim.diagnostic.toqflist(diags),
      })
      vim.cmd 'copen'
    elseif state == 1 then
      vim.fn.setloclist(0, {}, ' ', {
        title = 'Diagnostics (Errors only)',
        items = vim.diagnostic.toqflist(diags),
      })
      vim.cmd 'lopen'
    elseif state == 2 then
      vim.fn.setloclist(0, {}, ' ', {
        title = 'Diagnostics (All)',
        items = vim.diagnostic.toqflist(diags),
      })
      vim.cmd 'lopen'
    end
  end

  M.show_status_message()
end

-- Toggle function (4-way)
function M.toggle_diag_list()
  M.diag_state = (M.diag_state + 1) % 4
  if M.diag_state == 3 then
    vim.cmd 'lclose'
    vim.cmd 'cclose'
  else
    M.update_diag_list(M.diag_state)
  end
end

return M
