" MEMO {{{
" :help internal-variables {{{
"+----+-------------------+---------------------------------------------+
"| b: | buffer-variable   | Local to the current buffer.                |
"| w: | window-variable   | Local to the current window.                |
"| t: | tabpage-variable  | Local to the current tab page.              |
"| g: | global-variable   | Global.                                     |
"| l: | local-variable    | Local to a function.                        |
"| s: | script-variable   | Local to a :source'ed Vim script.           |
"| a: | function-argument | Function argument (only inside a function). |
"| v: | vim-variable      | Global, predefined by Vim.                  |
"+----+-------------------+---------------------------------------------+
"}}}
" :help map {{{
"+----------------------------------------------+--------------------------------------------------------------------------------+
"|commands:                                     |modes:                                                                          |
"| Variables | Constants |  Unset  |  Destroy   | Normal | Visual | Select | Operator-pending | Insert | Command-line | Lang-Arg |
"|   :map    | :noremap  | :unmap  | :mapclear  |  yes   |  yes   |  yes   |       yes        |   -    |      -       |    -     |
"|   :nmap   | :nnoremap | :nunmap | :nmapclear |  yes   |   -    |   -    |        -         |   -    |      -       |    -     |
"|   :vmap   | :vnoremap | :vunmap | :vmapclear |   -    |  yes   |  yes   |        -         |   -    |      -       |    -     |
"|   :omap   | :onoremap | :ounmap | :omapclear |   -    |   -    |   -    |       yes        |   -    |      -       |    -     |
"|   :xmap   | :xnoremap | :xunmap | :xmapclear |   -    |  yes   |   -    |        -         |   -    |      -       |    -     |
"|   :smap   | :snoremap | :sunmap | :smapclear |   -    |   -    |  yes   |        -         |   -    |      -       |    -     |
"|   :map!   | :noremap! | :unmap! | :mapclear! |   -    |   -    |   -    |        -         |  yes   |     yes      |    -     |
"|   :imap   | :inoremap | :iunmap | :imapclear |   -    |   -    |   -    |        -         |  yes   |      -       |    -     |
"|   :cmap   | :cnoremap | :cunmap | :cmapclear |   -    |   -    |   -    |        -         |   -    |     yes      |    -     |
"|   :lmap   | :lnoremap | :lunmap | :lmapclear |   -    |   -    |   -    |        -         |  yes*  |     yes*     |   yes*   |
"+-----------+-----------+---------+------------+--------+--------+--------+------------------+--------+--------------+----------+
"}}}
"}}}

" Variables {{{
"if has('win32') || has ('win64')
"    let s:osType = 'win'
"elseif has('macunix')
"if has('macunix')
let s:osType = 'macunix'
"else
"    let s:osType = 'unix'
"endif

function! s:GetTablineRight() abort "{{{
    let s:tablineRight = '%#TabLine# ' . strftime('%y-%m-%d %H:%M', s:currentTime) . ' '
    "if s:osType ==# 'macunix'
    let l:battery = system("pmset -g ps|egrep -o '[0-9]{1,3}%'|egrep -o '[0-9]{1,3}'|tr -d '\n'")
    let l:charge  = system("pmset -g ps|egrep -o 'discharging'|tr -d '\n'")
    if l:battery < 20
        if l:charge ==# 'discharging'
            let s:tablineRight = s:tablineRight . '%#KazuakiMError# ' . l:battery . '%% '
        else
            let s:tablineRight = s:tablineRight . '%#KazuakiMWarning# ' . l:battery . '%% '
        endif
    else
        let s:tablineRight = s:tablineRight . '%#KazuakiMInfo# ' . l:battery . '%% '
    endif
    "endif
    return s:tablineRight
endfunction "}}}

let s:currentTime  = ! exists('s:currentTime')  ? localtime() : s:currentTime
let s:envHome      = ! exists('s:envHome')      ? $HOME       : s:envHome
let s:envUser      = ! exists('s:envUser')      ? $USER       : s:envUser
let s:statuslineSwitch = ! exists('s:statuslineSwitch') ? 1   : s:statuslineSwitch
let s:swapFilePath = ! exists('s:swapFilePath') ? ''          : s:swapFilePath
let s:deinDir      = ! exists('s:deinDir')      ? s:envHome . '/.vim/dein.vim' : s:deinDir

if has('gui_running')
    let s:tablineRight = ! exists('s:tablineRight') ? s:GetTablineRight() : s:tablineRight
else
    let s:tablineRight = ''
endif
"}}}

" Common {{{
" encoding
set encoding=utf-8 fileencoding=utf-8 fileformats=unix,dos,mac
if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    set fileencodings=ucs-bom,utf-8,default,eucjp-ms,latin1,iso-2022-jp-3,cp932
elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    set fileencodings=ucs-bom,utf-8,default,euc-jisx0213,latin1,iso-2022-jp-3,cp932
else
    set fileencodings=ucs-bom,utf-8,default,euc-jp,latin1,iso-2022-jp,cp932
endif
scriptencoding utf-8

let g:mapleader = ','
noremap <Subleader> <Nop>
noremap <Neoleader> <Nop>
map <Space> <Subleader>
map ; <Neoleader>
augroup MyAutoCmd
    autocmd!
augroup END

function! s:AutoMkdir(dir) abort "{{{
    if !isdirectory(a:dir)
        call mkdir(a:dir, 'p')
    endif
endfunction "}}}

function! s:VimStart(backupDir, undoDir) abort "{{{
    "Check 256KB file size.
    if 262144 <= getfsize(expand('%:p'))
        call kazuakim#Minimal()
        return 1
    endif
    let s:syntaxToggle = 0
    return 0
endfunction "}}}

if has('vim_starting')
    "if s:osType ==# 'win'
    "    set runtimepath^=$HOME\.vim runtimepath+=$HOME\.vim\after
    "    if s:VimStart(s:envHome . '\.vim\backup\', s:envHome . '\.vim\undo\')
    "        finish
    "    endif
    "    " vimproc.vim {{{
    "    let g:vimproc#dll_path             = s:deinDir . '/repos/github.com/Shougo/vimproc.vim/lib/vimproc_win64.dll'
    "    let g:vimproc#download_windows_dll = 1
    "    "}}}
    "else
    if s:VimStart(s:envHome . '/.vim/backup/', s:envHome . '/.vim/undo/')
        finish
    endif
    "endif
endif

function! s:CheckString() abort "{{{
    let w:m1 = matchadd('KazuakiMCheckString', '\t\|\r\|\r\n\|\s\+$\|　')
    let w:m2 = matchadd('KazuakiMTodo',        'FIXME\|MEMO\|NOTE\|TODO\|XXX')
endfunction "}}}

function! KazuakiMGoDoc(cw) abort "{{{
    let l:line = getline('.')
    let l:cword_start_pos = searchpos('\V' . escape(a:cw, '\'), 'bcW', line('.'))
    let l:prefix_end_index = l:cword_start_pos[1] - 2
    let l:prefix = l:prefix_end_index >= 0 ? l:line[:l:prefix_end_index] : ''

    return matchstr(l:prefix, '\zs\k\+\ze\.$') . ' ' . a:cw
endfunction "}}}

function! s:RefMapping() abort "{{{
    if &filetype is# 'go'
        nmap <silent>K :<C-u>call<Space>go#doc#Open("new", "split", KazuakiMGoDoc(expand('<cword>')))<CR>
    else
        nmap <silent>K <Plug>(ref-keyword)
    endif
endfunction "}}}

function! s:FileTypeSyntaxOn() abort "{{{
    filetype plugin indent on
    syntax enable
    let s:syntaxToggle = 0
endfunction "}}}

function! s:FileTypeSyntaxOff() abort "{{{
    filetype off
    filetype plugin indent off
    syntax off
    let s:syntaxToggle = 1
endfunction "}}}

function! s:BufEnter() abort "{{{
    " Auto close VimDiff
    if winnr('$') is# 1 && (&l:diff || &filetype is# 'quickrun')
        quit

    " Duplicate ban
    elseif v:servername is# 'GVIM1'
        setlocal noswapfile viminfo=
        call remote_send('GVIM', '<ESC>:tabnew '.expand('%:p').'<CR>')
        call remote_foreground('GVIM')
        quit
    elseif v:servername is# 'VIM1'
        setlocal noswapfile viminfo=
        call remote_send('VIM', '<ESC>:tabnew '.expand('%:p').'<CR>')
        call remote_foreground('VIM')
        quit
    endif

    " Move current file(/directory) path
    if &filetype !=# 'go'
        execute 'lcd '. fnameescape(expand('%:p:h'))
    endif

    " Forcibly update
    set formatoptions-=c formatoptions-=b formatoptions+=j formatoptions-=t formatoptions-=v textwidth=0

    " Set StatusLine
    if &fileencoding is# 'utf-8'
        highlight StatusLine cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Grey   guibg=Grey
    else
        highlight StatusLine cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Yellow guibg=Yellow
    endif

    " Change Big file or Normal file.
    if 262144 <= getfsize(expand('%:p')) && s:syntaxToggle ==# 0
        call s:FileTypeSyntaxOff()
    elseif s:syntaxToggle ==# 1
        call s:FileTypeSyntaxOn()
    endif

    call s:RefMapping()
endfunction "}}}

function! s:BufReadPost() abort "{{{
    " memory cursol
    if line("'\"") > 1 && line("'\"") <= line('$')
        execute "normal! g`\""
    endif

    " Zun wiki http://www.kawaz.jp/pukiwiki/?vim#cb691f26 {{{
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
        let &fileencoding = &encoding
    endif
    "}}}

    "TODO: delte duplicate tab & window & buffer
    " http://kannokanno.hatenablog.com/entry/2013/05/31/205858
endfunction "}}}

"function! s:CursorHold() abort "{{{
"   if v:servername is# '' && $TMUX !=# ''
"       redraw!
"   endif
"endfunction "}}}

function! s:InsertLeave() abort "{{{
    set nopaste
    if &l:diff
        diffupdate
    endif
endfunction "}}}

function! s:VimEnter() abort "{{{
    " Forcibly update
    set ambiwidth=double showtabline=2
    call s:CheckString()
    call s:RefMapping()

    if &l:diff
        wincmd h
    endif

    if 0 < len(s:swapFilePath)
        call delete(s:swapFilePath)
        let s:swapFilePath = ''
    endif
endfunction "}}}

function! s:WinEnter() abort "{{{
    checktime
    call s:CheckString()
    call s:RefMapping()
endfunction "}}}

autocmd MyAutoCmd BufEnter             * call s:BufEnter()
autocmd MyAutoCmd BufReadPost          * call s:BufReadPost()
autocmd MyAutoCmd CmdwinEnter          * nmap <silent> <ESC><ESC> :quit<CR>
autocmd MyAutoCmd CmdwinLeave          * nunmap <ESC><ESC>
"autocmd MyAutoCmd CursorHold          * call s:CursorHold()
autocmd MyAutoCmd FocusGained          * checktime
autocmd MyAutoCmd SwapExists           * let s:swapFilePath = v:swapname
autocmd MyAutoCmd InsertLeave          * call s:InsertLeave()
autocmd MyAutoCmd QuickfixCmdPost *grep* cwindow
autocmd MyAutoCmd QuickfixCmdPost      * call kazuakim#QuickfixCmdPost()
autocmd MyAutoCmd VimEnter             * call s:VimEnter()
autocmd MyAutoCmd WinEnter             * call s:WinEnter()

autocmd MyAutoCmd BufNewFile,BufRead $HOME/.config/composer/vendor/*.php               setlocal tags=$HOME/.vim/tags/global.tags
autocmd MyAutoCmd BufNewFile,BufRead $HOME/work/dotfiles/.config/composer/vendor/*.php setlocal tags=$HOME/.vim/tags/global.tags

function! KazuakiMStatuslineSyntax() abort "{{{
    let l:ret = ale#statusline#Status()
    if 0 < len(l:ret)
        highlight StatusLine cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Magenta guibg=Magenta
    else
        highlight StatusLine cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Grey guibg=Grey
    endif
    return l:ret
endfunction "}}}

function! KazuakiMStatuslinePaste() abort "{{{
    if &paste is# 1
        return '[paste]'
    endif
    return ''
endfunction "}}}

function! KazuakiMStatuslineSwitch() abort "{{{
    if s:statuslineSwitch ==# 1
        set statusline=\ %t%{KazuakiMStatuslinePaste()}%m%r%h%w%q\ %{KazuakiMStatuslineSyntax()}%<%=%l/%L\ 
        let s:statuslineSwitch = 0
    else
        set statusline=\ %t%{KazuakiMStatuslinePaste()}%m%r%h%w%q\ %{KazuakiMStatuslineSyntax()}%<%=%F\ \|\ %Y\ \|\ %{&fileformat}\ \|\ %{&fileencoding}\ \|\ %l/%L\ 
        let s:statuslineSwitch = 1
    endif
endfunction "}}}

" http://d.hatena.ne.jp/thinca/20111204/1322932585
function! s:TabpageLabelUpdate(tabNumber) abort "{{{
    let l:highlight = a:tabNumber is# tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
    let l:bufnrs    = tabpagebuflist(a:tabNumber)
    let l:bufnr     = len(l:bufnrs)
    if l:bufnr is# 1
        let l:bufnr = ''
    endif
    let l:modified = len(filter(copy(l:bufnrs), 'getbufvar(v:val, "&modified")')) ? '[+]' : ''
    return '%' . a:tabNumber . 'T' . l:highlight . l:bufnr . ' ' . fnamemodify(bufname(l:bufnrs[tabpagewinnr(a:tabNumber) - 1]), ':t') . ' ' . l:modified . '%T%#TabLineFill#'
endfunction "}}}

function! KazuakiMTabLineUpdate() abort "{{{
    if has('gui_running') && 60 < abs(localtime() - s:currentTime)
        let s:currentTime  = localtime()
        let s:tablineRight = s:GetTablineRight()
    endif
    return join(map(range(1, tabpagenr('$')), 's:TabpageLabelUpdate(v:val)'), '|') . '%#TabLineFill#%T%=%#TabLineSel# ' . getcwd() . ' ' . s:tablineRight
endfunction "}}}

" Basic
set autoindent autoread
set backspace=indent,eol,start backup backupdir=$HOME/.vim/backup belloff=all breakindentopt=shift:0
set clipboard+=autoselect,unnamed cmdheight=1 concealcursor=i conceallevel=2 completeopt=longest,menu
set diffopt=filler,context:5,iwhite,horizontal directory=$HOME/.vim/swap display=lastline
set expandtab
set fillchars+=diff:* foldmethod=marker
set grepformat=%f:%l:%m,%f:%l%m,%f\ \ %l%m guioptions+=M
set helplang=ja hidden history=1000 hlsearch
set ignorecase iminsert=0 imsearch=-1 incsearch
set laststatus=2 nolazyredraw
set matchpairs+=<:> matchtime=1 mouse=
set nobomb noequalalways nofixendofline nogdefault noimcmdline noimdisable noruler notitle nowrap number
set pumheight=8
set scrolloff=999 shellslash shiftwidth=4 shortmess+=a shortmess+=I showbreak=> showcmd showmatch smartcase smartindent smarttab softtabstop=4 swapfile switchbuf=usetab
set synmaxcol=350
set tabline=%!KazuakiMTabLineUpdate() tabstop=4 titleold= ttyfast t_vb=
set undodir=$HOME/.vim/undo undofile updatecount=30 updatetime=1000
set viminfo='10,/100,:100,@100,c,f1,h,<100,s100,n~/.vim/viminfo/.viminfo virtualedit+=block
set wildmenu wildmode=longest:full,full wrapscan
set grepprg=grep\ -rnIH\ --exclude-dir=.svn\ --exclude-dir=.git\ --exclude-dir=coverage\ --exclude='*.cache'\ --exclude='*.log'\ --exclude='*min.js'\ --exclude='*min.css'
set wildignore+=*.bmp,*.gif,*.git,*.ico,*.jpeg,*.jpg,*.log,*.mp3,*.ogg,*.otf,*.png,*.qpf2,*.svn,*.ttf,*.wav,C,.DS_Store,.,..
let &runtimepath = &runtimepath . ',' . s:deinDir . '/repos/github.com/Shougo/dein.vim'
"set foldopen-=search
"helptags $HOME/.vim/dein.vim/repos/github.com/vim-jp/vimdoc-ja/doc
" Color
colorscheme kazuakim
" Mapping
"  ESC
inoremap jk <Esc>
inoremap kj <Esc>
"  Visual
xnoremap Y y`>
"  Fold
nnoremap zx :foldopen<CR>
"  Line
noremap 0 $
noremap 1 ^
nnoremap Y y$
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w> <C-g>u<C-w>
"  Tab
nnoremap gr gT
nnoremap ge :<C-u>call<Space>kazuakim#TabMove()<CR>
"  Window Size
nnoremap + <C-w>+
nnoremap - <C-w>-
nnoremap > <C-w>>
nnoremap < <C-w><
"  Cursor
nnoremap ga %
noremap <Down>  <C-f>
noremap <Up>    <C-b>
noremap <Right> $
noremap <Left>  ^
"  Sudo Write
nnoremap <Leader>w :<C-u>w<Space>!sudo<Space>tee<Space>%<Space>><Space>/dev/null<CR>
"  Paste
nmap <silent><expr><Leader>v ':set<Space>paste<CR><Insert><Right><C-r>+<ESC>'
cmap <M-v> <C-R><C-O>*
"  Replace
nnoremap R gR
"  Search
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'
nnoremap +* *N
"  Tags
nnoremap <Leader>] <C-]>
nnoremap <Leader>[ <C-o>
nmap <Leader>: :<C-u>call<Space>kazuakim#TagJumper()<CR>
"  Diff
nnoremap <Leader>df :<C-u>diffsplit<Space>
"  Register
nnoremap x "_x
nnoremap X "_x
" Wildmenu
cnoremap <Left>  <Space><BS><Left>
cnoremap <Right> <Space><BS><Right>
" Special word
noremap! ¥ \
" BookMark
noremap <Leader>b :<C-u>call<Space>KazuakimBookMark()<CR>
" $VIMRUNTIME/syntax/sql.vim
let g:sql_type_default = 'mysql'
" $VIMRUNTIME/syntax/php.vim
let g:php_baselib       = 1
let g:php_htmlInStrings = 1
let g:php_noShortTags   = 1
let g:php_sql_query     = 1
" $VIMRUNTIME/syntax/vim.vim
let g:vimsyn_embed = 1
" $VIMRUNTIME/ftplugin/sql.vim
let g:ftplugin_sql_objects        = 1
let g:ftplugin_sql_omni_key       = 1
let g:ftplugin_sql_omni_key_left  = 1
let g:ftplugin_sql_omni_key_right = 1
let g:ftplugin_sql_statements     = 1
let g:omni_sql_no_default_maps    = 1
" disable plugin
let g:did_install_default_menus = 1 "$VIMRUNTIME/menu.vim
let g:loaded_2html_plugin       = 1 "$VIMRUNTIME/plugin/tohtml.vim
let g:loaded_getscript          = 1 "$VIMRUNTIME/autoload/getscript.vim
let g:loaded_getscriptPlugin    = 1 "$VIMRUNTIME/plugin/getscriptPlugin.vim
let g:loaded_gzip               = 1 "$VIMRUNTIME/plugin/gzip.vim
let g:loaded_logiPat            = 1 "$VIMRUNTIME/plugin/logiPat.vim
let g:loaded_matchparen         = 1 "$VIMRUNTIME/plugin/matchparen.vim
let g:loaded_netrw              = 1 "$VIMRUNTIME/autoload/netrw.vim
let g:loaded_netrwFileHandlers  = 1 "$VIMRUNTIME/autoload/netrwFileHandlers.vim
let g:loaded_netrwPlugin        = 1 "$VIMRUNTIME/plugin/netrwPlugin.vim
let g:loaded_netrwSettings      = 1 "$VIMRUNTIME/autoload/netrwSettings.vim
let g:loaded_rrhelper           = 1 "$VIMRUNTIME/plugin/rrhelper.vim
let g:loaded_spellfile_plugin   = 1 "$VIMRUNTIME/plugin/spellfile.vim
let g:loaded_sql_completion     = 1 "$VIMRUNTIME/autoload/sqlcomplete.vim
let g:loaded_syntax_completion  = 1 "$VIMRUNTIME/autoload/syntaxcomplete.vim
let g:loaded_tar                = 1 "$VIMRUNTIME/autoload/tar.vim
let g:loaded_tarPlugin          = 1 "$VIMRUNTIME/plugin/tarPlugin.vim
let g:loaded_vimball            = 1 "$VIMRUNTIME/autoload/vimball.vim
let g:loaded_vimballPlugin      = 1 "$VIMRUNTIME/plugin/vimballPlugin.vim
let g:loaded_zip                = 1 "$VIMRUNTIME/autoload/zip.vim
let g:loaded_zipPlugin          = 1 "$VIMRUNTIME/plugin/zipPlugin.vim
" Vim
nnoremap <SID>[vim] <Nop>
nmap <Leader>f <SID>[vim]
nnoremap <SID>[vim]e :<C-u>tabnew<Space>$MYVIMRC<CR>
nnoremap <SID>[vim]w :<C-u>source<Space>$MYVIMRC<CR>
nnoremap <SID>[vim]s :<C-u>tabnew<Space>$HOME/.vim/vim-sqlfix/sqlfix.sql<CR>
nnoremap <SID>[vim]h :<C-u>source<Space>$VIMRUNTIME/syntax/colortest.vim<CR>
nnoremap <SID>[vim]c :<C-u>IndentLinesToggle<CR>
nnoremap <SID>[vim]p :<C-u>echo<Space>substitute(&runtimepath,<Space>',',<Space>'\n',<Space>'g')<CR>
"}}}

" VimDiff {{{
if &l:diff
    set cursorline
    "set clipboard+=autoselect,unnamed cursorline
    set statusline=\ %t\ %{KazuakiMStatuslinePaste()}\ %m\ %r\ %h\ %w\ %q%=%l/%L\ \|\ %{&fileformat}\ \|\ %{&fileencoding}\ 
    nnoremap <C-k> [c
    nnoremap <C-j> ]c
    nnoremap <C-h> do
    nnoremap <C-l> dp

    finish
else
    set nocursorline
    call KazuakiMStatuslineSwitch()

    autocmd MyAutoCmd InsertLeave * syntax clear neosnippetConcealExpandSnippets
endif
"}}}

" dein.vim {{{
let g:dein#install_process_timeout = 600
if dein#load_state(s:deinDir)
    call dein#begin(s:deinDir)
    "Not support yet.
    "'jodosha/vim-godebug': {'on_ft': 'go'},
    call dein#load_dict({
    \    'fatih/vim-go':                 {'on_ft': 'go'},
    \    'fuenor/qfixgrep':              {},
    \    'gcmt/wildfire.vim':            {},
    \    'glidenote/memolist.vim':       {},
    \    'junegunn/vim-easy-align':      {},
    \    'kannokanno/previm':            {'on_ft': 'markdown'},
    \    'KazuakiM/neosnippet-snippets': {'on_i': 1},
    \    'KazuakiM/vim-qfstatusline':    {},
    \    'KazuakiM/vim-sqlfix':          {},
    \    'koron/codic-vim':              {},
    \    'Kuniwak/vint':                 {'on_ft': 'vim'},
    \    'lervag/vimtex':                {'on_ft': 'tex'},
    \    'LeafCage/yankround.vim':       {},
    \    'mojako/ref-sources.vim':       {},
    \    'osyo-manga/vim-over':          {},
    \    'plasticboy/vim-markdown':      {'on_ft': 'markdown'},
    \    'rhysd/clever-f.vim':           {},
    \    'Shougo/dein.vim':              {},
    \    'Shougo/neocomplete.vim':       {'on_i': 1},
    \    'Shougo/neoinclude.vim':        {'on_i': 1},
    \    'Shougo/neosnippet.vim':        {'on_i': 1},
    \    'Shougo/vimproc.vim':           {'build': 'make'},
    \    'Shougo/denite.nvim':           {},
    \    'sjl/gundo.vim':                {'on_i': 1},
    \    'StanAngeloff/php.vim':         {'on_ft': 'php'},
    \    't9md/vim-quickhl':             {},
    \    'thinca/vim-prettyprint':       {'on_ft': 'vim'},
    \    'thinca/vim-quickrun':          {},
    \    'thinca/vim-qfreplace':         {},
    \    'thinca/vim-ref':               {},
    \    'tpope/vim-surround':           {},
    \    'tyru/open-browser.vim':        {},
    \    'vim-scripts/matchit.zip':      {},
    \    'w0rp/ale':                     {},
    \    'Yggdroot/indentLine':          {},
    \    'hail2u/vim-css3-syntax':       {'lazy':1},
    \    'mattn/emmet-vim':              {'lazy':1},
    \    'mustardamus/jqapi':            {'lazy':1},
    \    'pangloss/vim-javascript':      {'lazy':1},
    \    'thinca/vim-themis':            {'lazy':1},
    \    'tokuhirom/jsref':              {'lazy':1},
    \    'vim-jp/vimdoc-ja':             {'lazy':1},
    \    'vim-jp/vital.vim':             {'lazy':1},
    \    'KazuakiM/vim-ibm-bluemix':     {'lazy':1},
    \    'KazuakiM/vim-ms-translator':   {'lazy':1},
    \    'KazuakiM/vim-qfsigns':         {'lazy':1},
    \    'KazuakiM/vim-regexper':        {'lazy':1},
    \    'KazuakiM/vim-snippets':        {'lazy':1},
    \})
    call dein#end()
    call dein#save_state()
endif
filetype plugin indent on
syntax enable

" vim-go {{{
let g:go_doc_keywordprg_enabled = 0
let g:go_fmt_autosave = 1
let g:go_fmt_command = 'goimports'
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_arguments = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_types = 1
let g:go_highlight_variable_assignments = 1
let g:go_highlight_variable_declarations = 1
let g:go_info_mode = 'gocode'
let g:go_jump_to_error = 0
let g:go_snippet_engine = 'neosnippet'
"MEMO:I think ale is better than vim-go. Because vim-go checks all project-files.
"let g:go_metalinter_autosave = 1
nnoremap <expr><Subleader>fi ':GoImport ' . expand('<cword>')
"}}}

" qfixgrep {{{
let g:disable_MyGrep     = 1
let g:QFix_PreviewHeight = 20
let g:QFixWin_EnableMode = 1
nnoremap <expr><Leader>grek ':grep! '. expand('<cword>') .' '. kazuakim#Path2ProjectDirectory('%') .'<C-b><Right><Right><Right><Right><Right><Right>'
nnoremap <expr><Leader>grel ':grep!  '. kazuakim#Path2ProjectDirectory('%') .'<C-b><Right><Right><Right><Right><Right><Right>'
nnoremap <expr><Leader>greh ':grep! '. expand('<cword>') .' '. expand('%:p')
"MEMO:tabnew <C-w>gf
"}}}

" wildfire.vim {{{
let g:wildfire_fuel_map  = '<Enter>'
let g:wildfire_objects   = ["i'", 'i"', 'i`', 'i,', 'i)', 'i}', 'i]', 'i>', 'ip', 'it']
let g:wildfire_water_map = '<BS>'
"}}}

" vim-ms-translator {{{
"nnoremap <Leader>jj :<C-u>Mstranslator<CR>
"nnoremap <Leader>jk :<C-u>Mstranslator<Space>
"let g:mstranslator#Config = {
"\    'timers': 1
"\}
"}}}

" yankround.vim {{{
nmap p <Plug>(yankround-p)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)
let g:yankround_dir                 = s:envHome . '/.vim/yankround.vim'
let g:yankround_region_hl_groupname = 'YankRoundRegion'
let g:yankround_use_region_hl       = 1
"}}}

" indentLine {{{
let g:indentLine_faster = 1
"}}}

" codic-vim {{{
nnoremap <expr><Leader>dic ':Codic ' . expand('<cword>')
"}}}

" dein.vim
" memolist.vim {{{
nnoremap <SID>[unite] <Nop>
nmap <Leader>u <SID>[unite]
call denite#custom#alias('source', 'file_rec/git',      'file_rec')
call denite#custom#alias('source', 'file_rec/memolist', 'file_rec')
call denite#custom#option('default', 'prompt', '>')
call denite#custom#map('insert', 'jj',    '<denite:enter_mode:normal>')
call denite#custom#map('insert', "<C-j>", '<denite:move_to_next_line>')
call denite#custom#map('insert', "<C-k>", '<denite:move_to_previous_line>')
call denite#custom#var('file_rec/git', 'command', ['git', 'ls-files', '-co', '--exclude-standard'])
nnoremap <SID>[unite]f :<C-u>call<Space>KazuakiMDeniteFileRecGit()<CR>
function! KazuakiMDeniteFileRecGit() abort "{{{
    if finddir('.git', ';') != ''
        execute 'Denite file_rec/git:' . kazuakim#Path2ProjectDirectory('%') . ' -default-action=tabopen'
    else
        Denite file_rec -default-action=tabopen
    endif
endfunction "}}}

" memolist
nnoremap <SID>[memolist] <Nop>
nmap <Leader>m <SID>[memolist]
nnoremap <SID>[memolist]n :<C-u>MemoNew<CR>
nnoremap <SID>[memolist]l :<C-u>MemoList<CR>
let g:memolist_filename_prefix_none = 1
let g:memolist_template_dir_path    = s:envHome .'/.vim/memolist.vim'
let g:memolist_denite               = 1
let g:memolist_denite_option        = '-default-action=tabopen'
let g:memolist_denite_source        = 'file_rec/memolist'
"}}}

" vim-quickrun {{{
nnoremap <SID>[quickrun] <Nop>
nmap <Subleader>t <SID>[quickrun]
nnoremap <SID>[quickrun]t :<C-u>QuickRun<CR>
nnoremap <SID>[quickrun]f :<C-u>QuickRun<Space>phpfixer<CR>
nnoremap <SID>[quickrun]i :<C-u>QuickRun<Space>phpinfo<CR>
nnoremap <SID>[quickrun]r :<C-u>QuickRun<Space>phpunit<CR>
let g:quickrun_config = {
\    '_': {
\        'hook/close_buffer/enable_empty_data': 0,
\        'hook/close_buffer/enable_failure':    0,
\        'outputter':                           'multi:buffer:quickfix',
\        'outputter/buffer/close_on_empty':     1,
\        'outputter/buffer/split':              ':botright',
\        'runner':                              'job'
\    },
\    'go': {
\        'command':                         'go',
\        'cmdopt':                          'run',
\        'exec':                            '%c %o %s:p:t %a',
\        'outputter':                       'buffer',
\        'outputter/buffer/close_on_empty': 0,
\        'outputter/buffer/into':           0,
\        'outputter/buffer/split':          ':botright 7sp',
\        'tempfile':                        '%{tempname()}.go'
\    },
\    'json': {
\        'command':               'python',
\        'cmdopt':                '-m json.tool',
\        'exec':                  '%c %o %s:p',
\        'outputter':             'buffer',
\        'outputter/buffer/into': 1
\    },
\    'php': {
\        'command':                             'php',
\        'exec':                                '%c %s',
\        'hook/close_buffer/enable_empty_data': 0,
\        'hook/close_buffer/enable_failure':    0,
\        'outputter':                           'buffer',
\        'outputter/buffer/close_on_empty':     0,
\        'outputter/buffer/into':               0,
\        'outputter/buffer/split':              ':botright 7sp'
\    },
\    'phpfixer': {
\        'command':                'php-cs-fixer',
\        'cmdopt':                 'fix',
\        'exec':                   '%c %o %s:p',
\        'outputter':              'buffer',
\        'outputter/buffer/into':  1,
\        'outputter/buffer/split': ':botright 7sp',
\        'runner':                 'system'
\    },
\    'phpinfo': {
\        'command':   'php',
\        'cmdopt':    '-info',
\        'exec':      '%c %o',
\        'outputter': 'buffer'
\    },
\    'phpunit': {
\        'command':   'phpunit',
\        'exec':      '%c %s',
\        'outputter': 'buffer'
\    },
\    'plantuml': {
\        'command':               'plantuml',
\        'exec':                  '%c %s:p',
\        'outputter':             'error',
\        'outputter/error/error': 'quickfix'
\    },
\    'sql': {
\        'type': 'sql/mysql'
\    },
\    'sql/mysql': {
\        'exec':                  "%c %o < %s | sed -e 's/\t/|/g'",
\        'outputter':             'buffer',
\        'outputter/buffer/into': 1
\    },
\    'xml': {
\        'command':               'xmllint',
\        'cmdopt':                '--noblanks --nowrap --encode UTF-8 --format',
\        'exec':                  '%c %o %s:p',
\        'outputter':             'buffer',
\        'outputter/buffer/into': 1
\    }
\}
"}}}

" vital.vim {{{
let g:vitalizer#vital_dir = s:envHome . '/.vim/dein.vim/repos/github.com/vim-jp/vital.vim'
"}}}

" vim-qfreplace {{{
nnoremap <Leader>qr :<C-u>Qfreplace<CR>
"}}}

" vim-easy-align {{{
vnoremap <silent> <Leader>a :EasyAlign<CR>
let g:easy_align_delimiters = {
\    '=': {'pattern': '===\|!==\|<=>\|\(&&\|||\|<<\|>>\)=\|=\~[#?]\?\|=>\|[:+/*!%^=><&|.-]\?=[#?]\?', 'left_margin': 1, 'right_margin': 1, 'stick_to_left': 0},
\    '>': {'pattern': '>>\|=>\|>'},
\    '?': {'pattern': '?',                     'ignore_groups': ['String'], 'left_margin': 1, 'right_margin': 1},
\    '/': {'pattern': '//\+\|/\*\|\*/',        'ignore_groups': ['String']},
\    '#': {'pattern': '#\+',                   'ignore_groups': ['String'],                                                           'delimiter_align': 'l'},
\    '$': {'pattern': '\((.*\)\@!$\(.*)\)\@!', 'ignore_groups': ['String'],                   'right_margin': 0,                      'delimiter_align': 'l'},
\    ']': {'pattern': '[[\]]',                 'ignore_groups': ['String'], 'left_margin': 0, 'right_margin': 0, 'stick_to_left': 0},
\    ')': {'pattern': '[()]',                  'ignore_groups': ['String'], 'left_margin': 0, 'right_margin': 0, 'stick_to_left': 0},
\    'd': {'pattern': '\(\S\+\s*[;=]\)\@=',    'ignore_groups': ['String'], 'left_margin': 0, 'right_margin': 0}}
"}}}

" vim-quickhl {{{
nmap <Subleader>m <Plug>(quickhl-manual-this)
nmap <Subleader>M <Plug>(quickhl-manual-reset)
let g:quickhl_manual_colors = [
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Green        guibg=Green',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Magenta      guibg=Magenta',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Cyan         guibg=Cyan',
\    'cterm=NONE gui=NONE ctermfg=White guifg=White ctermbg=Brown        guibg=Brown',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Grey         guibg=Grey',
\    'cterm=NONE gui=NONE ctermfg=Grey  guifg=Grey  ctermbg=Blue         guibg=Blue',
\    'cterm=NONE gui=NONE ctermfg=White guifg=White ctermbg=DarkGreen    guibg=DarkGreen',
\    'cterm=NONE gui=NONE ctermfg=White guifg=White ctermbg=DarkMagenta  guibg=DarkMagenta',
\    'cterm=NONE gui=NONE ctermfg=White guifg=White ctermbg=DarkRed      guibg=DarkRed',
\    'cterm=NONE gui=NONE ctermfg=White guifg=White ctermbg=DarkCyan     guibg=DarkCyan',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=DarkGray     guibg=DarkGray',
\    'cterm=NONE gui=NONE ctermfg=White guifg=White ctermbg=DarkBlue     guibg=DarkBlue',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=Yellow       guibg=Yellow',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightGreen   guibg=LightGreen',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightMagenta guibg=LightMagenta',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightRed     guibg=LightRed',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightYellow  guibg=LightYellow',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightCyan    guibg=LightCyan',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightGray    guibg=LightGray',
\    'cterm=NONE gui=NONE ctermfg=Black guifg=Black ctermbg=LightBlue    guibg=LightBlue'
\]
"}}}

"vim-ibm-bluemix {{{
"nmap <Subleader>tt <C-o>:call<Space>ibm_bluemix#execute()<CR>
"nmap <Subleader>tk <C-o>:call<Space>ibm_bluemix#execute('')<Left><Left>
"let g:ibm_bluemix#config = {
"\    'source': 'ja',
"\    'target': 'en',
"\}
"}}}

" vim-sqlfix {{{
let g:sqlfix#Config = {'direcotry_path': s:envHome . '/.vim/vim-sqlfix'}
"}}}

" previm {{{
nnoremap <silent> <Leader>pre :<C-u>PrevimOpen<CR>
"}}}

" vim-ref {{{
let g:ref_no_default_key_mappings = 1
let g:ref_cache_dir               = s:envHome . '/.vim/vim-ref/cache'
let g:ref_detect_filetype         = {
\    'css':        'phpmanual',
\    'html':       ['phpmanual',  'javascript', 'jquery'],
\    'javascript': ['javascript', 'jquery'],
\    'php':        ['phpmanual',  'javascript', 'jquery']
\}
let g:ref_javascript_doc_path = s:envHome . '/.vim/dein.vim/repos/github.com/tokuhirom/jsref/htdocs'
let g:ref_jquery_doc_path     = s:envHome . '/.vim/dein.vim/repos/github.com/mustardamus/jqapi'
let g:ref_phpmanual_path      = s:envHome . '/.vim/vim-ref/php-chunked-xhtml'
let g:ref_use_cache           = 1
let g:ref_use_vimproc         = 1
"}}}

" open-browser.vim {{{
nmap <Leader>gx <Plug>(openbrowser-open)
"}}}

" clever-f.vim {{{
nmap f <Plug>(clever-f-f)
let g:clever_f_across_no_line = 0
let g:clever_f_smart_case     = 1
let g:clever_f_use_migemo     = 0
"}}}

" vim-over {{{
vnoremap <C-w> "ay
vnoremap <C-e> "by
nnoremap <expr><Leader>s    ':OverCommandLine<CR>%s/' . expand('<cword>') . '/' . expand('<cword>') . '/gc<Left><Left><Left>'
nnoremap <Leader>%s         :<C-u>OverCommandLine<CR>
nnoremap <expr><Subleader>s ':OverCommandLine<CR>%s/' . expand('<cword>') . '//gc<Left><Left><Left>'
nnoremap <Neoleader>s       :<C-u>OverCommandLine<CR>%s/<C-r>a/<C-r>b/gc
"}}}

" vim-surround {{{
nmap cs <Plug>Csurround
"}}}

" neosnippet-snippets
" neosnippet.vim
" neoinclude.vim
" neocomplete.vim {{{
imap <silent><expr><TAB> pumvisible() ? "\<C-n>" : neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
" neosnippet.vim
smap <silent><expr><TAB>  neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
nmap <silent><expr><TAB>  neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
imap <silent><expr><C-x>  KazuakiMNeoCompleteCr()
imap <silent><expr><CR>   KazuakiMNeoCompleteCr()
nmap <silent><S-TAB> <ESC>a<C-r>=neosnippet#commands#_clear_markers()<CR>
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS>  neocomplete#smart_close_popup()."\<C-h>"
"neocomplete.vim
let g:neocomplete#auto_completion_start_length = 3
let g:neocomplete#data_directory               = s:envHome .'/.vim/neocomplete.vim'
let g:neocomplete#delimiter_patterns           = {
\    'javascript': ['.'],
\    'php':        ['->', '::', '\'],
\    'ruby':       ['::']
\}
let g:neocomplete#enable_at_startup         = 1
let g:neocomplete#enable_auto_close_preview = 1
let g:neocomplete#enable_auto_delimiter     = 1
let g:neocomplete#enable_auto_select        = 0
let g:neocomplete#enable_fuzzy_completion   = 0
let g:neocomplete#enable_smart_case         = 1
let g:neocomplete#keyword_patterns          = {'_': '\h\w*'}
let g:neocomplete#lock_buffer_name_pattern  = '\.log\|.*quickrun.*\|.jax'
let g:neocomplete#max_keyword_width         = 30
let g:neocomplete#max_list                  = 8
let g:neocomplete#min_keyword_length        = 3
let g:neocomplete#sources                   = {
\    '_':          ['neosnippet', 'file',               'buffer'],
\    'css':        ['neosnippet',         'dictionary', 'buffer'],
\    'go':         ['neosnippet', 'file', 'omni',       'buffer'],
\    'html':       ['neosnippet', 'file', 'dictionary', 'buffer'],
\    'javascript': ['neosnippet', 'file', 'dictionary', 'buffer'],
\    'php':        ['neosnippet', 'file', 'dictionary', 'buffer']
\}
let g:neocomplete#sources#buffer#cache_limit_size  = 50000
let g:neocomplete#sources#buffer#disabled_pattern  = '\.log\|\.jax'
let g:neocomplete#sources#buffer#max_keyword_width = 30
let g:neocomplete#sources#dictionary#dictionaries  = {
\    '_':          '',
\    'css':        s:envHome . '/.vim/dict/css.dict',
\    'html':       s:envHome . '/.vim/dict/html.dict',
\    'javascript': s:envHome . '/.vim/dict/javascript.dict',
\    'php':        s:envHome . '/.vim/dict/php.dict'
\}
let g:neocomplete#sources#omni#input_patterns = {'go': '\h\w\.\w*'}
let g:neocomplete#use_vimproc = 1
"neoinclude.vim
let g:neoinclude#exts          = {'php': ['php', 'inc', 'tpl']}
let g:neoinclude#max_processes = 5
"neosnippet.vim
let g:neosnippet#data_directory                = s:envHome . '/.vim/neosnippet.vim'
let g:neosnippet#disable_runtime_snippets      = {'_' : 1}
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory            = s:envHome . '/.vim/dein.vim/repos/github.com/KazuakiM/neosnippet-snippets/neosnippets'
function! KazuakiMNeoCompleteCr() abort "{{{
    if pumvisible() is# 0
        return "\<CR>X\<C-h>"
    elseif neosnippet#expandable_or_jumpable()
        return "\<Plug>(neosnippet_expand_or_jump)"
    endif
    return "\<Left>\<Right>"
endfunction "}}}
"}}}

" ale {{{
let g:ale_echo_cursor               = 0
let g:ale_emit_conflict_warnings    = 0
let g:ale_go_gometalinter_options   = '--fast --enable=megacheck --enable=errcheck --disable=gotype'
let g:ale_history_enabled           = 0
let g:ale_history_log_output        = 0
let g:ale_javascript_eslint_options = '--cache --cache-file ' . s:envHome . '/.cache/eslint/eslintcache --config ' . s:envHome . '/.config/eslint/eslintrc --format compact --max-warnings 1 --no-color --no-ignore --quiet'
let g:ale_linters                   = {
\    'go':         ['gometalinter'],
\    'javascript': ['eslint'],
\    'php':        ['php']
\}
let g:ale_lint_on_enter            = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_text_changed     = 'never'
let g:ale_max_buffer_history_size = 0
let g:ale_pattern_options         = {
\    '\.min.js$': {'ale_enabled': 0}
\}
let g:ale_pattern_options_enabled        = 1
let g:ale_set_highlights                 = 1
let g:ale_set_signs                      = 1
let g:ale_sign_error                     = '.'
let g:ale_sign_warning                   = '.'
let g:ale_warn_about_trailing_whitespace = 0
nmap <silent> <Subleader>N <Plug>(ale_previous)
nmap <silent> <Subleader>n <Plug>(ale_next)
nmap <silent> <Subleader>a <Plug>(ale_toggle)
"}}}

" gundo.vim {{{
nnoremap cu :<C-u>call<Space>kazuakim#ClearUndo()<CR>
nnoremap u g-
nnoremap U g-
nnoremap <C-r> g+
"}}}

" emmet-vim {{{
"
" MEMO
" * URL: http://docs.emmet.io/cheat-sheet/
" * <C+y>,  :execute trigger key
" * html:5  && <C+y>,
" * div>ul>li.class#id_$$*5  && <C+y>,
"let g:user_emmet_complete_tag = 1
"let g:user_emmet_settings     = {
"\    'variables': {
"\        'lang':               'ja',
"\        'default_attributes': {
"\            'a': {
"\                'href': ''
"\            },
"\            'link': [
"\                {
"\                    'rel': 'stylesheet'
"\                },
"\                {
"\                    'href': ''
"\                }
"\            ]
"\        }
"\    },
"\    'html': {
"\        'filters':     'html',
"\        'indentation': '    '
"\    },
"\    'php' : {
"\        'extends': 'html',
"\        'filters': 'html,c'
"\    }
"\}
"let g:user_emmet_mode        = 'a'
"let g:user_emmet_leader_key = ''
"}}}

" vim-markdown {{{
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
"}}}

" Exclusive {{{
"if s:osType !=# 'macunix'
"endif
"
"if s:osType !=# 'win'
" memolist.vim {{{
let g:memolist_path = s:envHome .'/.vim/memolist.vim'
"}}}
" neoinclude.vim {{{
let g:neoinclude#delimiters = '\'
"}}}
"endif
"
"if s:osType !=# 'unix'
"endif
"}}}

" Only {{{
"if s:osType ==# 'macunix'
" mapping {{{
nnoremap ao :<C-u>!open<Space>-a<Space>
nnoremap aq :<C-u>!osascript<Space>-e<Space>'tell<Space>application<Space>""<Space>to<Space>quit'<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
nnoremap af :<C-u>!osascript<Space>-e<Space>'tell<Space>application<Space>""<Space>to<Space>activate'<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>
"}}}
" previm {{{
let g:previm_open_cmd = 'open -a "Google Chrome"'
"}}}

"elseif s:osType ==# 'win'
"    " previm {{{
"    let g:previm_open_cmd = 'C:/Program\ Files\ (x86)/Google/Chrome/Application/chrome.exe'
"    "}}}
"    " memolist.vim {{{
"    let g:memolist_path = '/cygwin64/home/' . $USER . '/.vim/memolist.vim'
"    "}}}
"    " neoinclude.vim {{{
"    let g:neoinclude#delimiters = '/'
"    "}}}
"
"elseif s:osType ==# 'unix'
"endif
"}}}

"}}}

" FileType {{{
function! s:GetMatchWords() abort "{{{
    let l:block_list = []
    for l:block in s:match_words_php_list
        let l:blockMatch = '\<' . join(l:block, '\>:\<') .'\>'
        call add(l:block_list, l:blockMatch)
    endfor

    for l:block in s:match_words_html_list
        let l:blockMatch = join(l:block, ':')
        call add(l:block_list, l:blockMatch)
    endfor

    return join(l:block_list, ',')
endfunction "}}}

let s:match_words_php_list  = [['do', 'while', 'endwhile'], ['for', 'endfor'], ['foreach', 'endforeach'], ['if', 'elseif', 'else', 'endif'], ['switch', 'case', 'default', 'endswitch']]
let s:match_words_html_list = [['<div', '</div>'], ['<form', '</form>'], ['<ol', '</ol>'], ['<p', '</p>'], ['<span', '</span>'], ['<table', '</table>'], ['<tbody', '</tbody>'],
\    ['<td', '</td>'], ['<thead', '</thead>'], ['<th', '</th>'], ['<tr', '</tr>'], ['<ul', '</ul>']]
let s:match_words = s:GetMatchWords()

autocmd MyAutoCmd BufNewFile,BufRead *.coffee    setlocal filetype=coffee
autocmd MyAutoCmd BufNewFile,BufRead *.tpl       setlocal filetype=php
autocmd MyAutoCmd BufNewFile,BufRead *.plantuml  setlocal filetype=plantuml
autocmd MyAutoCmd BufNewFile,BufRead *.snip*     setlocal filetype=snippets
autocmd MyAutoCmd BufNewFile,BufRead *.tex       setlocal filetype=tex
autocmd MyAutoCmd BufNewFile,BufRead *.vim*      setlocal filetype=vim
autocmd MyAutoCmd BufNewFile,BufRead *.{bin,exe} setlocal filetype=xxd
autocmd MyAutoCmd FileType html,js,php,xml syntax sync minlines=4000
autocmd MyAutoCmd FileType php             let b:match_words = s:match_words
"}}}

" Function {{{
nnoremap <F1> :<C-u>echo<Space>"\tFunction Key Help\nF1:Help(here!)\nF2:StatusLine\nF3:DataBase"<CR>
nnoremap <F2> :<C-u>call<Space>KazuakiMStatuslineSwitch()<CR>
nnoremap <F3> :<C-u>call<Space>kazuakim#DatabaseSwitch()<CR>
"}}}

" Other setting files {{{
" Environment setting file
source ~/.vim/vimrc.local
if isdirectory(expand('%:p')) ==# 1
    call KazuakimBookMark()
endif
"}}}


