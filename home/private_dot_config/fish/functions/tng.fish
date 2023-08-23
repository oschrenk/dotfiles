# requires `brew install sox`
function tng --description "Play ambient engine noise like Star Trek Next Generation"
  if test -n "$argv[1]"
    set gain "$argv[1]"
  else
    set gain "+5"
  end
  play -c2 -n synth whitenoise band -n 100 24 band -n 300 100 gain $gain
end
