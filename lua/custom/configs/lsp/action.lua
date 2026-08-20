local function defaultString(str, defaultStr)
  return str or (defaultStr or "")
end

local function expressComment(attrs)
  local cmd = "<ESC>O/**<CR>"
  for _, attr in ipairs(attrs) do
    cmd = cmd .. attr .. " <CR>"
  end
  cmd = cmd .. "<BS>/<ESC>" .. #attrs .. "kA"
  return cmd
end

local function markdownStrikethrough()
  local curr = vim.api.nvim_get_current_line()

  local strikethroughRegex = "^(%s*)~~(.-)%s*~~%s*$"

  local ok, _, indent, line = string.find(curr, strikethroughRegex)

  if ok ~= nil then
    vim.api.nvim_set_current_line(defaultString(indent) .. defaultString(line))
    return
  end

  local indentRegex = "^(%s*)(.-)%s*$"

  _, _, indent, line = string.find(curr, indentRegex)

  vim.api.nvim_set_current_line(defaultString(indent) .. "~~" .. defaultString(line) .. "~~" .. "  ")
end

return {
  goError               = "<ESC>oif err != nil {<CR>}<ESC>O",

  type_ignore           = "<ESC>A #type: ignore<ESC><CR>",

  tsExpectError         = "<ESC>O//@ts-expect-error ",

  tsxExpectError        = "<ESC>O{/** @ts-expect-error  */}<ESC>3hi",

  eslintTsDisable       = "<ESC>O// eslint-disable-next-line ",

  eslintTsxDisable      = "<ESC>O{/** eslint-disable-next-line */}<ESC>3hi",

  tsIgnoreError         = "<ESC>O//@ts-ignore ",

  tsxIgnoreError        = "<ESC>O{/** @ts-ignore  */}<ESC>3hi",

  jsDocComment          = "<ESC>O/**  */<ESC>2hi",

  expressComment        = expressComment({ "@desc", "@route", "@method", "@access" }),

  markdownStrikethrough = markdownStrikethrough
}
