function ds --description "Stop docker image by name"
    docker ps --format '{{.Names}}' \
        | fzf -m \
        | while read name
        docker update --restart=no $name
        docker stop $name
    end
end
