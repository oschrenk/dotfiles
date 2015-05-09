function user --description "Switch to user"
  echo $argv | read -l user_name
  set -l user_id (/usr/bin/id -u $argv)

  /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -switchToUserID $user_id
end
