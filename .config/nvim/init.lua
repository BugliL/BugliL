-- Configurazione Neovim usando solo funzionalità built-in

-- ============================================================================
-- Abilita filetype detection e syntax highlighting (DEVE essere all'inizio)
-- ============================================================================
vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')

-- Assicura che i file Lua abbiano il filetype corretto
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = '*.lua',
  callback = function()
    vim.bo.filetype = 'lua'
  end,
})

-- ============================================================================
-- LSP (Language Server Protocol) - Built-in
-- ============================================================================
-- Configurazione LSP usando il client built-in di Neovim
local lsp_servers = { 'pyright', 'tsserver' }

-- Funzione per avviare un server LSP
local function setup_lsp(server_name)
  local cmd = { server_name }
  -- Cerca il comando LSP nel PATH
  if vim.fn.executable(server_name) == 0 then
    -- Se non trovato, prova varianti comuni
    local variants = {
      pyright = { 'pyright-langserver', '--stdio' },
      tsserver = { 'typescript-language-server', '--stdio' },
    }
    if variants[server_name] then
      cmd = variants[server_name]
    else
      vim.notify('LSP server ' .. server_name .. ' non trovato', vim.log.levels.WARN)
      return
    end
  else
    cmd = { server_name, '--stdio' }
  end

  local config = {
    cmd = cmd,
    root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'package.json', 'pyproject.toml', 'setup.py' }, { upward = true })[1] or vim.fn.getcwd()),
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  }

  vim.lsp.start_client(config)
end

-- Avvia i server LSP configurati
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  callback = function()
    local ft = vim.bo.filetype
    if ft == 'python' then
      setup_lsp('pyright')
    elseif ft:match('^typescript') or ft:match('^javascript') then
      setup_lsp('tsserver')
    end
  end,
})

-- Keybindings LSP built-in
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local opts = { buffer = args.buf, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- ============================================================================
-- Completamento - Built-in
-- ============================================================================
vim.o.completeopt = 'menuone,noselect'
vim.o.omnifunc = 'v:lua.vim.lsp.omnifunc'

-- Abilita completamento automatico da LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.bo[args.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
  end,
})

-- Keybindings per completamento
vim.keymap.set('i', '<C-Space>', '<C-x><C-o>', { desc = 'Completamento LSP' })
vim.keymap.set('i', '<C-n>', '<C-x><C-n>', { desc = 'Completamento parola' })
vim.keymap.set('i', '<C-p>', '<C-x><C-p>', { desc = 'Completamento parola precedente' })

-- ============================================================================
-- Formattazione - Built-in LSP
-- ============================================================================
-- La formattazione è già gestita tramite vim.lsp.buf.format() nei keybindings LSP sopra
-- Per formattazione automatica al salvataggio (opzionale):
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    if vim.lsp.get_client_by_id(args.data.client_id).server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end
  end,
})

-- ============================================================================
-- Statusline - Built-in
-- ============================================================================
vim.o.statusline = table.concat({
  '%<%f',           -- Nome file
  '%h%m%r%w',      -- Flags (help, modified, read-only, preview)
  '%=',             -- Separatore (spinge il resto a destra)
  '%y',             -- Tipo file
  ' [%{&ff}]',      -- Formato file (unix/dos)
  ' %l:%c',         -- Linea:colonna
  ' %P',            -- Percentuale nel file
})

-- ============================================================================
-- Snippets - Built-in (Neovim 0.10+)
-- ============================================================================
-- I snippet built-in sono disponibili tramite vim.snippet
-- Esempio di snippet personalizzato:
if vim.snippet then
  vim.snippet.expand('function', {
    'function ${1:name}(${2:args})',
    '  ${3:-- body}',
    'end',
  })
end

-- ============================================================================
-- Ricerca file - Built-in commands
-- ============================================================================
-- Usa :find per trovare file (richiede 'path' configurato)
vim.opt.path:append({ '**' })  -- Cerca ricorsivamente

-- Keybindings per ricerca built-in
vim.keymap.set('n', '<leader>ff', ':find ', { desc = 'Trova file' })
vim.keymap.set('n', '<leader>fg', ':grep ', { desc = 'Cerca nel testo' })
vim.keymap.set('n', '<leader>fb', ':buffers<CR>', { desc = 'Lista buffer' })
vim.keymap.set('n', '<leader>fo', ':oldfiles<CR>', { desc = 'File recenti' })

-- ============================================================================
-- Impostazioni generali
-- ============================================================================
vim.o.number = true            -- Numeri di riga
vim.o.relativenumber = true    -- Numeri relativi
vim.o.wrap = false             -- Disabilita l'andamento automatico delle righe
vim.o.tabstop = 4              -- Numero di spazi per un tab
vim.o.shiftwidth = 4           -- Indentazione per i comandi di spostamento
vim.o.expandtab = true         -- Usa spazi invece di tab
vim.o.smartindent = true       -- Abilita l'indentazione intelligente
vim.o.autoindent = true        -- Indentazione automatica
vim.o.smartcase = true         -- Attivare il "smart case" nella ricerca
vim.o.hlsearch = false         -- Disabilita l'evidenziazione dei risultati di ricerca
vim.o.incsearch = true         -- Ricerca incrementale
vim.o.ignorecase = true        -- Ignora maiuscole/minuscole durante la ricerca
vim.o.termguicolors = true     -- Abilita i colori TrueColor nel terminale
vim.o.swapfile = false         -- Disabilita la creazione di file di swap
vim.o.backup = false           -- Disabilita i file di backup
vim.o.writebackup = false      -- Disabilita il backup durante la scrittura

-- Finestre
vim.o.splitright = true         -- Le nuove finestre orizzontali saranno aperte a destra
vim.o.splitbelow = true         -- Le nuove finestre verticali saranno aperte sotto

-- Cursore sempre al centro dello schermo
vim.o.scrolloff = 999           -- Mantiene il cursore sempre al centro verticalmente
vim.o.sidescrolloff = 999       -- Mantiene il cursore sempre al centro orizzontalmente

-- ============================================================================
-- Mappature dei tasti
-- ============================================================================
vim.g.mapleader = " "  -- Imposta il leader key come spazio

vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })   -- Salvataggio con Ctrl+s
vim.api.nvim_set_keymap('n', '<C-q>', ':q<CR>', { noremap = true, silent = true })   -- Esci con Ctrl+q
vim.api.nvim_set_keymap('n', '<leader>h', ':nohlsearch<CR>', { noremap = true, silent = true }) -- Disabilita evidenziazione ricerca

-- ============================================================================