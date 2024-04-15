function sbt --description "run sbt only with build.sbt file present in pwd"
    if test -e (pwd)/build.sbt
        command sbt $argv
    else
        echo "Missing build.sbt file" 1>&2
        return 1
    end
end
