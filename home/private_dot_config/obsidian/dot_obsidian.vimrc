" Requires the obsidian-vimrc-support plugin.
"   https://github.com/esm7/obsidian-vimrc-support
"
" Inspiration:
" - https://github.com/chrisgrieser/.config/blob/main/obsidian/vimrc/obsidian-vimrc.vim
" -https://github.com/huyz/dot-vim/blob/9d77cf7562f2b3e5740bb4c69dbdc6c85688f309/.obsidian.vimrc
"
" Docs
"   https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md
"
" Tips
" - to list all Obsidian commands, run `:obcommand` and go to JS console.
"
" ###########################
" BASE
" ###########################

" Yank to system clipboard
set clipboard=unnamed

" ###########################
" KEY MAPPINGS
" ###########################
unmap <Space>

" Have j and k navigate visual lines rather than logical ones
nmap j gj
nmap k gk
" I like using H and L for beginning/end of line
nmap H ^
nmap L $

" <Esc> clears highlights
nnoremap <Esc> :nohl<CR>

" Emulate vim folding command
exmap togglefold obcommand editor:toggle-fold
exmap unfoldall obcommand editor:unfold-all
exmap foldall obcommand editor:fold-all
nnoremap za :togglefold<CR>
nnoremap zc :togglefold<CR>
nnoremap zm :foldall<CR>
nnoremap zo :togglefold<CR>
nnoremap zr :unfoldall<CR>
nnoremap zz :foldall<CR>

" Splits
exmap splitVertical obcommand workspace:split-vertical
exmap splitHorizontal obcommand workspace:split-horizontal
nnoremap <C-\> :splitVertical<CR>
nnoremap <C--> :splitHorizontal<CR>

" focus
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusBottom obcommand editor:focus-bottom
exmap focusTop obcommand editor:focus-top
nmap <C-h> :focusLeft<CR>
nmap <C-l> :focusRight<CR>
nmap <C-j> :focusBottom<CR>
nmap <C-k> :focusTo<CR>

exmap exReveal obcommand file-explorer:reveal-active-file
nnoremap <Space>r :exReveal<CR>

" [o]ption: [s]pellcheck
exmap spellcheck obcommand editor:toggle-spellcheck
nnoremap <Space>os :spellcheck<CR>

" open [p]lugin [d]irectory
exmap openPluginDir jscommand { view.app.openWithDefaultApp(view.app.vault.configDir + '/plugins'); }
nnoremap <Space>pd :openPluginDir<CR>

" [o]pen [c]onfig
exmap openThisVimrc jscommand { view.app.openWithDefaultApp('.obsidian.vimrc') }
nnoremap <Space>oc :openThisVimrc<CR>

" toggle
exmap toggleLeft obcommand app:toggle-left-sidebar
exmap toggleRight obcommand app:toggle-right-sidebar
exmap toggleTabs obcommand obsidian-hider:toggle-tab-containers
nmap <Space>tl :toggleLeft<CR>
nmap <Space>tt :toggleTabs<CR>
nmap <Space>tr :toggleRight<CR>

" [g]oto [x]link (= Follow Link under cursor)
exmap followLinkUnderCursor obcommand editor:follow-link
nmap gx :followLinkUnderCursor<CR>
