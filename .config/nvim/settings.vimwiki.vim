let wiki_1 = {}
let wiki_1.path = '~/Documents/Wiki/'
let wiki_1.syntax = 'markdown'
let wiki_1.ext = '.md'

" Name of wiki-file that holds all links to dated wiki files
let wiki_1.diary_index = 'journal'
" Name of the header in |vimwiki-option-diary_index| where links to dated wiki-files are located.
let wiki_1.diary_header = 'Journal'
" update the table of contents when the current wiki page is saved
let wiki_1.auto_toc = 1

let g:vimwiki_list = [wiki_1]

" ============================
" Keyboard mappings
" ============================
source ~/.config/nvim/plugged/vim-shortcut/plugin/shortcut.vim

Shortcut! <Leader>ww vimwiki | Open the first wiki index
Shortcut! <Leader>wi vimwiki | Open the first diary index
Shortcut! <Leader>w<Leader>w vimwiki | Open diary wiki-file for today
Shortcut! <Leader>w<Leader>y vimwiki | Open diary wiki-file for yesterday
Shortcut! <Leader>w<Leader>m vimwiki | Open diary wiki-file for tomorrow
Shortcut! gl* vimwiki | Make a list item with * out of a normal line
Shortcut! gl- vimwiki | Make a list item with - out of a normal line
Shortcut! gln vimwiki | Increase the "done" status
Shortcut! glp vimwiki | Decrease the "done" status
Shortcut! <C-Space> vimwiki | Toggle checkbox of a list item on/off
Shortcut! gl<Space> vimwiki | Remove checkbox from list item
