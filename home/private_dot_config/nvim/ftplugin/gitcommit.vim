setlocal spell

" when commiting add [TICKET], and enter insert mode
" if body is empty it's a new commit
if getline(1) == ""
  let branch = trim(system('git branch --show-current 2>/dev/null'))
  let ticket_match = matchstr(branch, '\v[A-Z]+-[0-9]+')
  " only add prefix when branch name matches
  if ticket_match != ""
    call append(0, [ticket_match . " ", "", "branch: " . branch])
    execute "norm k"
  endif
" otherwise we are probably amending
else
  execute "norm $"
end
" start in insert mode
startinsert!
