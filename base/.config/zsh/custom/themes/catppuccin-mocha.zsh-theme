johnnei_git_branch() {
	local ref
	ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
	local ret=$?

	if [[ $ret == 0 ]]; then
		echo -n "%F{#b4befe}  ${ref#refs/heads/}"
	elif [[ $ret == 128 ]]; then
		# Not a git repo
		return
	else
		# Not on a branch
		ref=$(git rev-parse --short HEAD 2> /dev/null) || return
		echo -n "%F{#b4befe}  $ref"
	fi
}

johnnei_precmd() {
	git_branch=$(eval johnnei_git_branch)
	PROMPT="%F{#89b4fa}%n@%m %F{#f5c2e7} %~$git_branch%{$reset_color%} $ "
}

add-zsh-hook precmd johnnei_precmd
