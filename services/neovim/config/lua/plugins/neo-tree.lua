return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = {
          ".DS_Store",
          "thumbs.db",
        },
      },
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
  },
}
