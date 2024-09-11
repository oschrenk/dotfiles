# adaptation of 
# https://github.com/arp242/uni/blob/master/dmenu-uni
function emoji --description "Find emoji"
    uni -c e all | fzf | cut -d ' ' -f1 | tr -d \n | string trim | pbcopy
end
