return {
    "vim-pandoc/vim-pandoc",
    "vim-pandoc/vim-pandoc-syntax",
    config = function()
        vim.keymap.set('n', '<leader>md', function()
            vim.cmd(":Pandoc html --mathjax --mathml")
            
			--builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
    end
}
