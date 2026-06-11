local utils = require("custom.utils")

local lspaction = require("custom.configs.lsp.action")

local Lsp = {}

local group = vim.api.nvim_create_augroup("lsp_format_on_save", { clear = false })

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


local function on_attach(_, bufnr)
  vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    group = group,
    callback = function()
      vim.lsp.buf.format({ bufnr = bufnr, async = false })
    end,
    desc = "[lsp] format on save",
  })
end

Lsp.lua = {
  lua_ls = {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    on_attach = on_attach,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
            [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
            [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  },
}

local function non_deno_root_dir(bufnr, on_dir)
  local root_markers = { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' }
  root_markers = { root_markers, { '.git' } }

  local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
  local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
  local project_root = vim.fs.root(bufnr, root_markers)

  if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
    return
  end
  if deno_root and (not project_root or #deno_root >= #project_root) then
    return
  end

  on_dir(project_root or vim.fn.getcwd())
end

local function prettier_on_attach(_, bufnr)
  vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    group = group,
    callback = prettier_format,
    desc = "[lsp] format on save",
  })
end
local function ts_on_attach(_, bufnr)
  vim.keymap.set('n', '<leader>je', lspaction.tsExpectError,
    { noremap = true, silent = true, desc = "insert expects-errors" })

  vim.keymap.set('n', '<leader>ji', lspaction.tsIgnoreError,
    { noremap = true, silent = true, desc = "insert ignore-errors" })

  vim.keymap.set('n', '<leader>jc', lspaction.jsDocComment, { noremap = true, silent = true, desc = "insert jsDoc" })

  vim.keymap.set('n', '<leader>pe', lspaction.expressComment,
    { noremap = true, silent = true, desc = "insert express/server comment" })

  vim.keymap.set('n', '<leader>jse', lspaction.tsxExpectError,
    { noremap = true, silent = true, desc = "insert tsx expects-errors" })

  vim.keymap.set('n', '<leader>jsi', lspaction.tsxIgnoreError,
    { noremap = true, silent = true, desc = "insert tsx ignore-errors" })

  vim.keymap.set('n', '<leader>jd', lspaction.eslintTsDisable,
    { noremap = true, silent = true, desc = "insert ts eslint disable" })

  vim.keymap.set('n', '<leader>jsd', lspaction.eslintTsxDisable,
    { noremap = true, silent = true, desc = "insert tsx eslint disable" })


  prettier_on_attach(_, bufnr)
end

local TsFileTypes = { "javascript", "typescript" }
local ReactFileTypes = { "javascriptreact", "typescriptreact" }

Lsp.ts = {
  tailwindcss = {
    cmd = { 'tailwindcss-language-server', "--stdio" },
    filetypes = ReactFileTypes,
    root_dir = function(bufnr, on_dir)
      local root_markers = { 'tailwind.config.js' }
      local project_root = vim.fs.root(bufnr, root_markers)

      if (project_root) then
        on_dir(project_root)
      end
    end,
  },

  deno_ls = {
    cmd = { 'deno', 'lsp' },
    cmd_env = { NO_COLOR = true },
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
    },

    root_dir = function(bufnr, on_dir)
      local root_markers = { 'deno.lock', 'deno.json', 'deno.jsonc' }
      root_markers = { root_markers, { '.git' } }
      local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
      local deno_lock_root = vim.fs.root(bufnr, { 'deno.lock' })
      local project_root = vim.fs.root(bufnr, root_markers)

      if
          (deno_lock_root and (not project_root or #deno_lock_root > #project_root))
          or (deno_root and (not project_root or #deno_root >= #project_root))
      then
        on_dir(project_root or deno_lock_root or deno_root)
      end
    end,
  },

  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    on_attach = ts_on_attach,
    filetypes = utils.extend(TsFileTypes, ReactFileTypes),
    root_dir = non_deno_root_dir
  },

  -- tsgo = {
  --   cmd = { "tsgo", "--lsp", "--stdio" },
  --   on_attach = ts_on_attach,
  --   filetypes = TsFileTypes,
  --   root_dir = non_deno_root_dir
  -- },
}

Lsp.go = {
  gopls = {
    on_attach = function(client, bufnr)
      vim.keymap.set('n', '<leader>ee', lspaction.goError, { noremap = true, silent = true, desc = "Error Block" })
      vim.keymap.set('i', '<C-e>', lspaction.goError, { noremap = true, silent = true, desc = "Error Block" })

      on_attach(client, bufnr)
    end,

    cmd = { "gopls" },
    filetypes = { "go", "gomod" },
    settings = {
      gopls = {
        completeUnimported = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
        },
      },
    }
  },

  -- templ = {
  --   cmd = { 'templ', 'lsp' },
  --   filetypes = { 'templ' },
  --   root_markers = { 'go.work', 'go.mod', '.git' },
  -- }
}

Lsp.c = {
  clangd = {
    cmd = {
      "clangd",
      "--clang-tidy",
      "--background-index",
      "--enable-config"
    },
    on_attach = on_attach,
    filetypes = { "c", "cpp" }
  },
}

Lsp.sql = {
  postgres_lsp = {
    cmd = { "postgres-language-server", "lsp-proxy" },
    on_attach = on_attach,
    filetypes = { "sql" },
  },
}

Lsp.elixir = {
  elixirls = {
    cmd = { "language_server.sh" },
    on_attach = on_attach,
    filetypes = { "elixir" }
  },

}

local function python_on_attach(client, bufnr)
  vim.keymap.set('n', '<leader>tt', lspaction.type_ignore, { noremap = true, silent = true, desc = "Type Ignore" })
  vim.keymap.set('i', '<C-t>', lspaction.type_ignore, { noremap = true, silent = true, desc = "Type Ignore" })

  on_attach(client, bufnr)
end

Lsp.python = {
  ruff = {
    cmd = { 'ruff', 'server' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    filetypes = { "python" },
    on_attach = python_on_attach
  },

  pyright = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = {
      'pyrightconfig.json',
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
    },
    on_attach = python_on_attach
  },

  djlsp = {
    cmd = { 'djlsp' },
    filetypes = { 'html', 'htmldjango' },
    root_markers = {
      'pyrightconfig.json',
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
    },
    on_attach = on_attach
  }
}

-- local rust = {
--   rust_analyzer = {
--     filetypes = { "rust" },
--   },
--
-- }

Lsp.utility = {
  bashls = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'bash', 'sh' },
    on_attach = on_attach,
  },

  jsonls = {
    cmd = { "vscode-json-language-server", "--stdio" },
    on_attach = prettier_on_attach,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
    filetypes = { "json", "jsonc" },
  },

  cssls = {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    init_options = { provideFormatter = true },
    single_file_support = true,
    settings = {
      css = { validate = true },
      scss = { validate = true },
      less = { validate = true },
    },
    on_attach = on_attach
  },

  html = {
    cmd = { 'vscode-html-language-server', '--stdio' },
    filetypes = { 'html', 'templ' },
    on_attach = on_attach,
    single_file_support = true,
    init_options = {
      provideFormatter = true,
      embeddedLanguages = { css = true, javascript = true },
      configurationSection = { 'html', 'css', 'javascript' },
    }
  },
}

local function LspConfig(table)
  for k, v in pairs(table) do
    vim.lsp.config(k, v)
    vim.lsp.enable(k)
  end
end

return {
  load_lsp = function()
    for _, lsp in pairs(Lsp) do
      LspConfig(lsp)
    end

    -- vim.api.nvim_create_autocmd('LspAttach', {
    --   callback = function(args)
    --     local client = vim.lsp.get_client_by_id(args.data.client_id)
    --     if client and client.server_capabilities.completionProvider then
    --       vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true })
    --     end
    --   end,
    -- })

    vim.diagnostic.config({ virtual_text = true, float = true, virtual_lines = true })

    require("core.utils").load_mappings "lspconfig"
  end
}
