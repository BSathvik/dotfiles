local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.opt.laststatus = 2

local required_servers = {
  "dockerls",
  "html",
  "clangd",
  "rust_analyzer",
  "pyright",
  "lua_ls",
  "jsonnet_ls",
  "gopls",
  "rnix",
}

require("lazy").setup({
  "christoomey/vim-tmux-navigator",

  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.comment").setup({})
      -- nix commentstring isn't set by default
      vim.cmd([[autocmd FileType nix setlocal commentstring=#%s]])
      require("mini.surround").setup({})
      require("mini.move").setup({
        mappings = {
          -- visual mode
          down = "∆",
          up = "˚",
          -- normal mode
          line_down = "∆",
          line_up = "˚",
        },
      })
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- Note taking
  {
    "nvim-neorg/neorg",
    -- macOS requires GCC with C++14 support
    -- CC=gcc nvim -c "TSInstall norg"
    build = ":Neorg sync-parsers",
    ft = "neorg",
    event = "VeryLazy",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        command = [[!cd ~/Documents/gdrive/notes && git add . && git commit -m "update notes" && git push origin]],
        pattern = "*.norg",
      })

      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.keybinds"] = { -- Adds pretty icons to your documents
            config = {
              neorg_leader = "<Space>",
            },
          },
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/Documents/gdrive/notes",
              },
              default_workspace = "notes",
            },
          },
        },
      })
    end,
  },

  -- UI to select things (files, grep results, open buffers...)
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "xiyaowong/telescope-emoji.nvim",
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
      })

      local git_root = function()
        -- TODO: There's most definitely a better way to do this
        local out = vim.api.nvim_cmd(
          { cmd = "!", args = { "git rev-parse --show-toplevel" } },
          { output = true }
        )
        local _, _, repo_root = string.find(out, "\n\n(.*)\n")
        return repo_root
      end

      -- Enable telescope fzf native
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("emoji")

      vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers)
      vim.keymap.set("n", "<leader>sb", require("telescope").extensions.file_browser.file_browser)
      vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string)
      vim.keymap.set("n", "<leader>ss", require("telescope.builtin").live_grep)
      vim.keymap.set("n", "<leader>sr", require("telescope.builtin").lsp_references)
      vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles)
      vim.keymap.set("n", "<leader>e", require("telescope").extensions.emoji.emoji)
      vim.keymap.set("n", "<leader>sg", function()
        require("telescope.builtin").find_files({ cwd = git_root() })
      end)
      vim.keymap.set("n", "<leader>sh", function()
        require("telescope.builtin").live_grep({ cwd = git_root() })
      end)
      vim.keymap.set("n", "<leader>#", function()
        require("telescope.builtin").find_files({ cwd = "~/Documents/gdrive/notes" })
      end)
      vim.keymap.set("n", "<leader>@", function()
        require("telescope.builtin").live_grep({ cwd = "~/Documents/gdrive/notes" })
      end)
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Aesthetics
  {
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({})
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    config = function()
      require("kanagawa").setup()
    end,
  },

  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup()
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",

    config = function()
      require("todo-comments").setup({
        keywords = {
          TODO = { icon = " ", color = "warning" },
        },
      })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim", -- Add git related info in the signs columns and popups
    event = "BufReadPost",

    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
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
          map("n", "<leader>gS", gs.stage_buffer)
          map("n", "<leader>gu", gs.undo_stage_hunk)
          map("n", "<leader>gR", gs.reset_buffer)
          map("n", "<leader>gp", gs.preview_hunk)
          map("n", "<leader>gb", gs.blame_line)
          map("n", "<leader>gB", function()
            gs.blame_line({ full = true })
          end)
          map("n", "<leader>gd", gs.diffthis)
          map("n", "<leader>gD", function()
            gs.diffthis("~")
          end)
        end,
      })
    end,
  },

  {
    "ruifm/gitlinker.nvim",
    config = function()
      require("gitlinker").setup({
        opts = {
          add_current_line_on_normal_mode = true,
          action_callback = require("gitlinker.actions").open_in_browser,
          print_url = true,
        },
        callbacks = {
          ["github.kensho.com"] = require("gitlinker.hosts").get_github_type_url,
        },
        mappings = "<leader>go",
      })
    end,
  },

  { "sindrets/diffview.nvim" },

  -- tree-sitter for parsing, syntax highlighting and much more
  {
    "nvim-treesitter/nvim-treesitter",

    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        modules = {},
        sync_install = false,
        ensure_installed = {},
        ignore_install = {},
        highlight = {
          enable = true, -- false will disable the whole extension
        },
        auto_install = true,
        indent = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          },
        },
        refactor = {
          highlight_definitions = {
            -- don't want to highlight node under cursor all the time
            enable = false,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
          },
        },
      })
    end,
  },

  -- Non-LSP language support (formatters mostly)
  { "nathangrigg/vim-beancount" },

  {
    "mhartington/formatter.nvim",

    event = "VeryLazy",
    config = function()
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        command = [[FormatWrite]],
        pattern = "*",
      })

      local util = require("formatter.util")

      require("formatter").setup({
        logging = true,
        filetype = {
          lua = {
            require("formatter.filetypes.lua").stylua,
          },
          nix = {
            require("formatter.filetypes.nix").nixpkgs_fmt,
          },
          rust = {
            require("formatter.filetypes.rust").rustfmt,
          },
          python = {
            function()
              return {
                exe = "black",
                args = { "-q", "-S", "-l", 100, "-" },
                stdin = true,
              }
            end,
          },
          jsonnet = {
            function()
              return {
                exe = "jsonnetfmt",
                args = {
                  "--comment-style",
                  "s",
                  "--string-style",
                  "d",
                  util.get_current_buffer_file_path(),
                },
                stdin = true,
              }
            end,
          },
        },
      })
    end,
  },

  -- LSP Installer and configuration
  {
    "williamboman/mason.nvim",
    event = "VeryLazy",

    config = function()
      require("mason").setup({})
      if not require("mason-registry").is_installed("stylua") then
        vim.cmd([[MasonInstall stylua]])
      end
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",

    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = required_servers,
        -- Don't automagically install server configured by lspconfig, add to required_servers
        automatic_installation = false,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = "BufReadPost",
    dependencies = { "hrsh7th/nvim-cmp", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
        vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      -- nvim-cmp supports additional completion capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      -- nvim api discovery
      -- Make runtime files discoverable to the server
      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")

      -- Enable the following language servers
      for _, lsp in ipairs(required_servers) do
        lspconfig[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          -- "rust-analyzer.diagnostics.disabled":
          settings = {
            ["rust-analyzer"] = {
              diagnostics = {
                disabled = { "unresolved-proc-macro" },
              },
            },
            python = {
              analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                useLibraryCodeForTypes = false,
              },
            },
            Lua = {
              runtime = {
                version = "LuaJIT",
                path = runtime_path,
              },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
            },
          },
        })
      end

      lspconfig["html"].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "htmldjango" },
      })
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "crispgm/cmp-beancount",
      "neovim/nvim-lspconfig",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local luasnip = require("luasnip")
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          keyword_length = 3,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", max_item_count = 10 },
          { name = "luasnip", max_item_count = 10 },
          {
            name = "beancount",
            keyword_length = 1,
            max_item_count = 20,
            option = {
              account = "~/Documents/accounts/ledger.beancount",
            },
          },
        }, {
          { name = "buffer", max_item_count = 10 },
        }),
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer", max_item_count = 10 },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path", max_item_count = 10 },
        }, {
          { name = "cmdline", max_item_count = 10 },
        }),
      })

      -- disbale for neorg
      cmp.setup.filetype({ "norg" }, {
        sources = {},
      })
    end,
  },
})

vim.filetype.on = true

local set = vim.opt -- set options

set.gcr = "a:blinkon100"
set.background = "dark"

set.colorcolumn = "100"
-- set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
--Set tab width
set.tabstop = 8 -- We don't want be using tab chars
set.softtabstop = 2 -- # spaces used by >> <<
set.shiftwidth = 2 -- # spaces used by tab/backspace
set.expandtab = true
set.smarttab = true

--Set relative line number
set.number = true
set.relativenumber = true
-- only highlight the number
set.cursorline = true
set.cursorlineopt = "both"

set.clipboard = "unnamedplus"

--Set highlight on search
set.hlsearch = true

--Enable break indent
set.breakindent = true

--Save undo history
set.undofile = true

--Case insensitive searching UNLESS /C or capital in search
set.ignorecase = true
set.smartcase = true

--Decrease update time
set.signcolumn = "yes"

-- Set completeopt to have a better completion experience
set.completeopt = "menuone,noselect"

set.list = true

-- Setup autocmds

-- to change to light mode
vim.cmd([[colorscheme kanagawa]])

vim.keymap.set("n", "<leader>/", ":noh<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "H", "^", { noremap = true, silent = true })
vim.keymap.set("n", "L", "$", { noremap = true, silent = true })

-- Remap space as leader key
vim.keymap.set({ "n", "v" }, "<leader>", "<Nop>", { silent = true })

-- Save file
vim.keymap.set("n", "<C-s>", ":update<CR>", { noremap = true, silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Setup shortcuts for switching buffer
vim.keymap.set("n", "<C-m>", ":bnext<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-n>", ":bprevious<CR>", { noremap = true, silent = true })

-- Hide all other split windows
vim.keymap.set("n", "<C-w>z", ":vertical resize<CR>", { noremap = true, silent = true })

-- Copy full path name of file into clipboard
vim.keymap.set("n", "<C-w>y", ":!echo $PWD/% | pbcopy<CR>", { noremap = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

local function urlencode(url)
  if url == nil then
    return
  end

  local char_to_hex = function(c)
    return string.format("\\%%%02X", string.byte(c))
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  return url
end

vim.api.nvim_create_user_command("Maps", function()
  local left, right = vim.api.nvim_buf_get_mark(0, "<"), vim.api.nvim_buf_get_mark(0, ">")
  local text = vim.api.nvim_buf_get_text(0, left[1] - 1, left[2], right[1] - 1, right[2], {})
  text = urlencode(table.concat(text, "+"))
  vim.api.nvim_command("!open 'https://google.com/maps/search/" .. text .. "'")
end, { range = true })
