return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Configurar denols
        denols = {
          root_dir = function(fname)
            -- Usa el directorio del archivo actual como root
            return vim.fn.fnamemodify(fname, ":h")
          end,
          -- Configuraciones adicionales para denols
          init_options = {
            enable = true,
            lint = true,
            unstable = false,
          },
          single_file_support = true,
        },
        -- Desactivar tsserver para evitar conflictos
        tsserver = {
          autostart = false,
          root_dir = function()
            return nil -- Nunca iniciar tsserver
          end,
        },
      },
      setup = {
        denols = function(_, opts)
          local lspconfig = require("lspconfig")
          lspconfig.denols.setup({
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "json" },
            root_dir = function(fname)
              return vim.fn.fnamemodify(fname, ":h") -- Usar directorio del archivo actual
            end,
            init_options = opts.init_options,
            single_file_support = true,
          })
          return true -- Evita la configuración automática
        end,
      },
    },
  },
}
