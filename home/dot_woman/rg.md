# ripgrep

**Basics**

`rg 'pattern'` search for pattern in current dir
`rg 'pattern\w*'` search for regex pattern in current dir

**Filtering**

* respects local `.ignore`, `.rgignore`, and `.gitignore`
* respects git's global `core.excludesFile`

`rg --hidden 'pattern'` includes hidden files
`rg pattern '*.rs'` filters by extension
`rg 'pattern' --type rust` filters by type
`rg --type-list` to list available types

**Output**

`rg -l regex` only print filename
`rg --files-with-matches regex` only print filename

**Replace**

`rg fast README.md --replace FAST` replace fast with FAST

