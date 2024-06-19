{ pkgs, ... }:

{
  globals.mapleader = " ";

  keymaps = [
    { mode = "n"; key = "<C-s>"; action = ":write<CR>"; options.silent = true; }
    { mode = "i"; key = "<C-s>"; action = "<cmd>write<CR><esc>"; options.silent = true; }

    { mode = "n"; key = "<C-m>"; action = ":bn<CR>"; options.silent = true; }
    { mode = "n"; key = "<C-n>"; action = ":bp<CR>"; options.silent = true; }
  ];

  opts = {
    background = "dark";

    colorcolumn = "100";
    tabstop = 8; # We don't want be using tab chars
    softtabstop = 2; # spaces used by >> <<
    shiftwidth = 2; # spaces used by tab/backspace
    expandtab = true;
    smarttab = true;

    relativenumber = true;

    cursorline = true; # Highlight the number
    cursorlineopt = "both";

    clipboard = "unnamedplus";

    # Set highlight on search
    hlsearch = true;

    # Enable break indent
    breakindent = true;

    # Save undo history
    undofile = true;

    # Case insensitive searching UNLESS /C or capital in search
    ignorecase = true;
    smartcase = true;

    # Decrease update time
    signcolumn = "yes";

    # Set completeopt to have a better completion experience
    completeopt = "menuone,noselect";
  };

  # colorschemes.kanagawa.enable = true;

  plugins.lazy = with pkgs.vimPlugins; {
    enable = true;

    plugins = [
      vim-closer

      vim-tmux-navigator
      # Formatter for beancount
      vim-beancount
      vim-startuptime

      todo-comments-nvim
      comment-nvim

      surround-nvim

      diffview-nvim

      {
        pkg = telescope-nvim;
        dependencies = [ plenary-nvim telescope-fzy-native-nvim ];
        config = ''
          function()
            require("telescope").setup({})

            vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers)
            vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files)
            vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string)
            vim.keymap.set("n", "<leader>ss", require("telescope.builtin").live_grep)
            vim.keymap.set("n", "<leader>sr", require("telescope.builtin").lsp_references)
            vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles)
          end
        '';
      }

      {
        pkg = lualine-nvim;
        config = ''
          function()
            require("lualine").setup({
              options = {
                theme = "gruvbox_dark",
                section_separators = "",
                component_separators = "",
              },
            })
          end
        '';
      }

      { 
        pkg = bufferline-nvim; 
        event = "VeryLazy";
        config = ''function() require("bufferline").setup() end''; 
      }

      { pkg = markdown-preview-nvim; ft = [ "markdown" ]; }

       nvim-treesitter-parsers.nix

      {
        pkg = nvim-treesitter;
        dependencies = [ nvim-treesitter-parsers.nix ];
      }
      
      { 
        pkg = nvim-colorizer-lua;
        event = "VeryLazy";
      }

      {
        pkg = gitsigns-nvim;
        dependencies = [ plenary-nvim ];
        config = ''
          function() 
            require("gitsigns").setup({
              on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                  opts = opts or {}
                  opts.buffer = bufnr
                  vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]g", function()
                  if vim.wo.diff then
                    return "]g"
                  end
                  vim.schedule(function()
                    gs.next_hunk()
                  end)
                  return "<Ignore>"
                end, { expr = true })

                map("n", "[g", function()
                  if vim.wo.diff then
                    return "[g"
                  end
                  vim.schedule(function()
                    gs.prev_hunk()
                  end)
                  return "<Ignore>"
                end, { expr = true })

                -- Actions
                map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>")
                map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>")
                map("n", "<leader>gu", gs.undo_stage_hunk)
                map("n", "<leader>gp", gs.preview_hunk)
                map("n", "<leader>gb", gs.blame_line)
              end,
            })
          end
        '';
      }
    ];
  };
}

# { pkgs, ... }:
#
# {
#   globals.mapleader = " ";
#
#   opts = {
#     background = "dark";
#
#     colorcolumn = "100";
#     tabstop = 8; # We don't want be using tab chars
#     softtabstop = 2; # spaces used by >> <<
#     shiftwidth = 2; # spaces used by tab/backspace
#     expandtab = true;
#     smarttab = true;
#
#     relativenumber = true;
#
#     cursorline = true; # Highlight the number
#     cursorlineopt = "both";
#
#     clipboard = "unnamedplus";
#
#     # Set highlight on search
#     hlsearch = true;
#
#     # Enable break indent
#     breakindent = true;
#
#     # Save undo history
#     undofile = true;
#
#     # Case insensitive searching UNLESS /C or capital in search
#     ignorecase = true;
#     smartcase = true;
#
#     # Decrease update time
#     signcolumn = "yes";
#
#     # Set completeopt to have a better completion experience
#     completeopt = "menuone,noselect";
#   };
#
#   colorschemes.kanagawa.enable = true;
#
#   # Plugins available as modules in nixvim
#   plugins = {
#     # Tabs at the top
#     bufferline.enable = true;
#
#     # Row above command line. Mode/branch/filename
#     lualine = {
#       enable = true;
#
#       theme = "gruvbox_dark";
#       sectionSeparators = { left = ""; right = ""; };
#       componentSeparators = { left = ""; right = ""; };
#     };
#
#     # Make todo comments pop-out
#     todo-comments.enable = true;
#
#     # See git changes by color lines along the number line
#     gitsigns.enable = true;
#
#     # Open links to git repos
#     gitlinker.enable = true;
#
#     # Run :OpenDiffView to see side-by-side github style diff
#     diffview.enable = true;
#
#     treesitter.enable = true;
#     treesitter-textobjects.enable = true;
#
#     # Search pop-up for files/grep
#     telescope = {
#       enable = true;
#       extensions.fzf-native.enable = true;
#
#       keymaps = {
#         "<leader>sf" = "find_files";
#         "<leader>ss" = "live_grep";
#         "<leader>sw" = "grep_string";
#         "<leader><space>" = "buffers";
#       };
#     };
#
#     # See in-line colors rendered in neovim when there are hex values
#     nvim-colorizer.enable = true;
#
#     markdown-preview.enable = true;
#
#     comment.enable = true;
#
#     surround.enable = true;
#     # TODO: Block move plugin
#
#     # Note taking
#     # TODO: Why doesn't Neorg command work
#     # neorg = {
#     #   enable = true;
#     #   lazyLoading = true;
#     #   modules = {
#     #     "core.defaults" = { };
#     #     "core.concealer" = { };
#     #     "core.keybinds" = {
#     #       config = {
#     #         neorg_leader = "<Space>";
#     #       };
#     #     };
#     #     "core.dirman" = {
#     #       config = {
#     #         workspaces = {
#     #           notes = "~/Documents/gdrive/notes";
#     #         };
#     #         default_workspace = "notes";
#     #       };
#     #     };
#     #   };
#     # };
#   };
#
#   keymaps = [
#     { mode = "n"; key = "<C-s>"; action = ":write<CR>"; options.silent = true; }
#     { mode = "i"; key = "<C-s>"; action = "<cmd>write<CR><esc>"; options.silent = true; }
#
#     { mode = "n"; key = "<C-m>"; action = ":bn<CR>"; options.silent = true; }
#     { mode = "n"; key = "<C-n>"; action = ":bp<CR>"; options.silent = true; }
#   ];
#
#   # Plugins _not_ available as modules for nixvim
#   extraPlugins = with pkgs.vimPlugins; [
#     # Move between neovim windows and tmux panes with <C-h>, <C-j>, <C-k>, <C-l>
#     vim-tmux-navigator
#     # Formatter for beancount
#     vim-beancount
#     vim-startuptime
#   ];
# }
