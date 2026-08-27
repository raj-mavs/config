local function crlf_remover()
  vim.cmd("%s/\\r//g")
end

return {
  load_commands = function()
    vim.api.nvim_create_user_command("Crlf", crlf_remover, { desc = "Remove annoying crlf" })
  end
}
