function my-httrack --description "Download some websites for offline reading"
    httrack \
        --update \
        "https://typealias.com" \
        "https://quii.gitbook.io" \
        "https://htmx.org" \
        "https://www.kotlinprimer.com" \
        -O "$HOME/Downloads/httrack" \
        "-*typealias.com/pl/*" \
        "-*typealias.com/es/*" \
        "-*typealias.com/tr/*"
end
