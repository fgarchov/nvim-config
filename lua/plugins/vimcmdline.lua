return {
    "jalvesaq/vimcmdline",
    config = function()
        vim.g.cmdline_in_buffer = 0
        vim.g.cmdline_map_start = '<leader>cs'
        vim.g.cmdline_map_send = '<leader>ce'
        vim.g.cmdline_map_quit = '<leader>cq'
    end
}
