local function prettier_format()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local text = table.concat(lines, '\n')

  local file = vim.api.nvim_buf_get_name(0)

  local result = vim.system({
    "prettier", "--stdin-filepath", file
  }, {
    stdin = text
  }):wait()


  if result.code ~= 0 then
    vim.notify(result.stderr, vim.log.levels.ERROR)
    return
  end

  local view = vim.fn.winsaveview()

  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n", { plain = true }))

  vim.fn.winrestview(view)
end

return {
  load_commands = function()
    vim.api.nvim_create_user_command("Prettier", prettier_format, { desc = "Run prettier format" })
  end
}
