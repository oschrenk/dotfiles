
`cat foo.txt | xargs -I % sh -c 'echo %; mkdir %'`
