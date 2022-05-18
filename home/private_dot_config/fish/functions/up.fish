function up --description "Navigate file tree up"
  if test \( (count $argv) -eq 0 \)
    cd ..
  else
    for x in (seq $argv[1])
      cd ..
    end
  end
end
