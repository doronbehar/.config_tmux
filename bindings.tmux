# {{{ change prefix-key:
set-option -g prefix C-s
unbind-key C-b
bind-key C-s send-prefix
set-option -g mode-keys vi
# }}}

# {{{1 General
# Show clock (who the hell uses it?)
unbind-key t
# run commands faster
bind-key -n M-r command-prompt
# }}}1

# {{{1 Clients Navigation
# Switch to the last client (using 'M-[' and 'M-]' for next/previous clients)
unbind-key L
# {{{1 Clients Manipulation
# make renaming current session easier:
bind-key '$' command-prompt -I "rename-session "
# }}}1

# {{{1 Windows Navigation
unbind-key p
unbind-key n
bind-key -n C-PageUp previous-window
bind-key -n C-PageDown next-window
bind-key -n M-h previous-window
bind-key -n M-l next-window
# Move to the next/previous window with an activity marker
unbind-key M-p
unbind-key M-n
# Switch to the last window
unbind-key l
# Switch to the windows indexed `0-9`
unbind-key 0
unbind-key 1
unbind-key 2
unbind-key 3
unbind-key 4
unbind-key 5
unbind-key 6
unbind-key 7
unbind-key 8
unbind-key 9
# {{{1 Windows Manipulation
# See https://unix.stackexchange.com/a/525770/135796 for reason of version check
# See https://stackoverflow.com/a/40902312/4935114 for how we parse version this way
run-shell 'if echo $TMUX | grep -q tmux; then executable=tmux; else executable=tmate; fi; $executable setenv -g TMUX_VERSION $($executable -V | sed -En "s/^$executable ([0-9]+(.[0-9]+)?).*/\1/p"); $executable setenv -g TMUX_EXE $executable'
if-shell -b '[ $(printf "%d" "$TMUX_VERSION") -ge 3 ]' " \
	bind-key -n M-PageUp { swap-window -t -1; previous-window }; \
	bind-key -n M-PageDown { swap-window -t +1; next-window }; \
	bind-key -n C-S-PageUp { swap-window -t -1; previous-window }; \
	bind-key -n C-S-PageDown { swap-window -t +1; next-window }" " \
	bind-key -n M-PageUp swap-window -t -1; \
	bind-key -n M-PageDown swap-window -t +1; \
	bind-key -n C-S-PageUp swap-window -t -1; \
	bind-key -n C-S-PageDown swap-window -t +1"
# Prompt for an index to move the current window
unbind-key .
# splitting vertically
unbind-key '"'
bind-key v split-window -v -c '#{pane_current_path}'
#bind-key s split-window -v -c '#{pane_current_path}' # (Extremley vim like)
# Splitting horizontally
unbind-key %
bind-key h split-window -h -c '#{pane_current_path}'
# Creating new window
unbind-key c
bind-key -n M-n new-window -c '#{pane_current_path}'
# make renaming windows and session process easier
unbind-key ,
bind-key n command-prompt -I "rename-window "
# Killing a window: Safer to unbind it and bind only `kill-pane` with confirmation
unbind-key &
# Rotate the panes in the current window forwards
unbind-key C-o
bind-key r rotate-window -U
# Rotate the panes in the current window backwards
unbind-key M-o
bind-key R rotate-window -D
# }}}1
# {{{ Windows configuration
# better format for automatic windows names
set-option -g automatic-rename-format '#{b:pane_current_path} :: #{pane_current_command}'
# }}}

# {{{1 Panes Navigation
unbind-key Up
unbind-key Down
unbind-key Left
unbind-key Right
# from: https://github.com/christoomey/vim-tmux-navigator#add-a-snippet
vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
if-shell 'uname | grep -qE "(MSYS|MINGW|CYGWIN)"' \
    "set-option -g @is_vim_cmd 'powershell.exe -NonInteractive -NoProfile -File $XDG_CONFIG_HOME/tmux/is_vim_ancestor.ps1'" \
    "set-option -g @is_vim_cmd \"ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +${vim_pattern}$'\""
bind-key -n C-h if-shell "#{@is_vim_cmd}" "send-keys C-h" "select-pane -L"
bind-key -n C-j if-shell "#{@is_vim_cmd}" "send-keys C-j" "select-pane -D"
bind-key -n C-k if-shell "#{@is_vim_cmd}" "send-keys C-k" "select-pane -U"
bind-key -n C-l if-shell "#{@is_vim_cmd}" "send-keys C-l" "select-pane -R"
# Display panes
unbind-key q
# {{{1 Panes Manipulation
# select the next pane in the current window
unbind-key o
# Resizing the pane in steps of 1 cell
unbind-key C-Up
unbind-key C-Down
unbind-key C-Left
unbind-key C-Right
# Resizing the pane in steps of 5 cell
unbind-key M-Up
unbind-key M-Down
unbind-key M-Left
unbind-key M-Right
# Resizing the panes in steps of 1 cell (without prefix)
bind-key -n M-Right resize-pane -R
bind-key -n M-Left resize-pane -L
bind-key -n M-Down resize-pane -D
bind-key -n M-Up resize-pane -U
# Imitating the vim mappings to resizing panes ('windows' in vim) over others
bind-key | resize-pane -x 200
bind-key _ resize-pane -y 200
# Other manipulation for panes:
# Stolen from: http://superuser.com/questions/266567/tmux-how-can-i-link-a-window-as-split-window
bind-key j command-prompt -p "create pane from:" "join-pane -s ':%%'"
# Take the current pane and create a new window out of it.
unbind-key !
bind-key b break-pane
# Kill the current pane
unbind-key x
bind-key -n M-q confirm-before -p "kill-pane #P? (y/n)" kill-pane
#}}}1

# {{{1 Layouts
# Change panes layout
unbind-key space
bind-key -n M-space next-layout
unbind-key M-1
unbind-key M-2
unbind-key M-3
unbind-key M-4
unbind-key M-5
# }}}1

# {{{1 Copy and Paste:
unbind-key [
unbind-key PageUp
bind-key -n M-c copy-mode
unbind-key ]
# The best script there is: https://github.com/doronbehar/tmux-url-select
bind-key -n M-- run-shell ~/.local/bin/tmux-url-select
if-shell '[[ "$TMUX_EXE" == "tmux" ]]' " \
	bind-key -T copy-mode-vi v send-keys -X begin-selection; \
	bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'tmux load-buffer -'" " \
	bind-key -t vi-copy v begin-selection; \
	bind-key -t vi-copy y copy-pipe 'tmux load-buffer -'"
# make the use of e and w more like in my .vimrc
if-shell '[[ "$TMUX_EXE" == "tmux" ]]' " \
	bind-key -T copy-mode-vi e send-keys -X next-word; \
	bind-key -T copy-mode-vi w send-keys -X previous-word; \
	bind-key -T copy-mode-vi E send-keys -X next-space; \
	bind-key -T copy-mode-vi W send-keys -X previous-space" " \
	bind-key -t vi-copy e next-word; \
	bind-key -t vi-copy w previous-word; \
	bind-key -t vi-copy E next-space; \
	bind-key -t vi-copy W previous-space"
# Show paste buffers
unbind-key '#'
bind-key @ show-buffer
# Choose which buffer to paste interactivly from (just like in vim)
unbind-key =
bind-key '"' choose-buffer
# }}}1

# {{{1 Macros
# Enable running a command in all panes and windows:
bind-key E command-prompt -p "Command:" \
	"run  \"tmux list-sessions                  -F '##{session_name}'        | xargs -I SESS \
			tmux list-windows  -t SESS          -F 'SESS:##{window_index}'   | xargs -I SESS_WIN \
			tmux list-panes    -t SESS_WIN      -F 'SESS_WIN.##{pane_index}' | xargs -I SESS_WIN_PANE \
			tmux send-keys     -t SESS_WIN_PANE '%1' Enter\""
# reload configuration
bind-key R display 'sourcing ~/.tmux.conf' \; source-file ~/.tmux.conf
# }}}1

# vim:ft=tmux:foldmethod=marker
