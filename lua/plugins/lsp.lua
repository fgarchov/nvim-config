-- lua/plugins/lsp.lua

return {
  "neovim/nvim-lspconfig",

  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },

  config = function()
    local lspconfig = require("lspconfig")
    local mason = require("mason")
    local masonlspconfig = require("mason-lspconfig")
    local util = require("lspconfig.util")

    local root_files = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'build.sh', -- buildProject
        'configure.ac', -- AutoTools
        'run',
        'compile',
    }

    mason.setup()
    masonlspconfig.setup({
        ensure_installed = { 'clangd', 'rust_analyzer', 'jedi_language_server' }
        })

    lspconfig.rust_analyzer.setup({})
    lspconfig.clangd.setup({
            on_attach = attach,
            cmd = {
                "clangd",
                "--header-insertion=never",
                "--background-index",
                "--clang-tidy",
                "--completion-style=detailed",
                "-j=4",
            },
	        root_dir = function(fname)
			    return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
		    end,
            single_file_support = true,
	        init_options = {
		        compilationDatabasePath= vim.fn.getcwd() .. "/build",
	        },
        })

    lspconfig.jedi_language_server.setup({
            on_attach = attach,
            cmd = { 'jedi-language-server' },
        })

    local cmp = require('cmp')
    local cmp_select = { behavior = cmp.SelectBehavior.Select },
    cmp.setup({
       snippet = {
           expand = function(args)
               require('luasnip').lsp_expand(args.body)
           end,
       },
       mapping = cmp.mapping.preset.insert({
           ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
           ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
           ['<C-y>'] = cmp.mapping.confirm({ select = true }),
           ["<C-Space>"] = cmp.mapping.complete(),
       }),
       sources = cmp.config.sources({
           { name = 'nvim_lsp' },
           { name = 'luasnip' },
       },
       {
           {name = 'buffer' },
       },
       {
           {name = 'path'},
       },
       {
           {name = 'lsp-signature-help'},
       }),

    })

    -- Global mappings.
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
          vim.lsp.buf.format { async = true }
        end, opts)
      end,
    })
  end,
}
