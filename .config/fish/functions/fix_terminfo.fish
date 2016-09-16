function fix_terminfo --description "Fix terminfo so that Ctrl+h works in neowin"
  cd $HOME/.config/nvim
  # Fun escaping backslash
  infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\\177/' > $TERM.ti
  tic $TERM.ti
  cd -
end
