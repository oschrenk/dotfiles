function work --description "Configure env for work"
    # OpenVPN ignores `-j` open
    open -a "OpenVPN Connect" -j
    # Slack ignores `-j` open
    open -a Slack -j
    # 
end
