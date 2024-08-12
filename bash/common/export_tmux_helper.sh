function atmux()
{
    if [[ ! -n $TMUX ]]; then
	tmux_info=`tmux info 2>&1`
	if [[ ${tmux_info} == *"no server running"* ]]; then
	    echo "tmux is not launched"
	    return
	else
	    # get the IDs
	    ID="`tmux list-sessions`"
	    if [[ -z "$ID" ]]; then
		tmux new-session
	    else
		create_new_session="new session"
		start_without_tmux="shell"
		ID="`echo -e \"$ID\" | fzf | cut -d: -f1`"
		if [[ -n "$ID" ]]; then
		    tmux attach-session -t "$ID"
		else
		    return
		fi
	    fi
	fi
    else
	echo "quit or detach the current tmux session"
	return
    fi
}
export -f atmux
