function compile-ssh --description "Concatenate ssh config files"
  set -l ssh_config_mine  $HOME/.ssh/config
  set -l ssh_config_base  $HOME/.ssh/config.base
  set -l ssh_config_d $HOME/.ssh/config.d

  echo "" > $ssh_config_mine
  cat $ssh_config_base > $ssh_config_mine
  for config in $ssh_config_d/*
    echo "" >> $ssh_config_mine
    cat $config >> $ssh_config_mine
  end
end
