return {
  applyMappings = function(table)
    for mode, config in pairs(table) do
      for lhs, rhs in pairs(config) do
        vim.keymap.set(mode, lhs, rhs[1], { desc = rhs[2] })
      end
    end
  end,

  extend = function(list1, list2)
    for key, value in pairs(list2) do
      if type(key) == "number" then
        table.insert(list1, value)
      end
    end

    return list1
  end,

  defaultString = function(str, defaultStr)
    return str or (defaultStr or "")
  end,
}
