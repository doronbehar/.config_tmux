## Taken from: https://github.com/hamvocke/dotfiles/blob/master/tmux/.tmux.conf

# {{{1 messages
set -g message-command-style bg=black
set -ag message-command-style fg=blue
set -g message-style fg=colour232
set -ag message-style bg=yellow
set -ag message-style bold
# {{{1 panes
set -g pane-active-border-style bg=colour236
set -ag pane-active-border-style fg=colour51
set -g pane-border-style bg=colour235
set -ag pane-border-style fg=colour238
# {{{1 statusbar
set -g status-style bg=colour234
set -ag status-style dim
set -ag status-style fg=colour137
set -g status-interval 2
set -g status-justify left
set -g status-left ''
set -g status-left-length 20
set -g status-position bottom
set -g status-right '#[fg=colour240]<#[fg=default]#[bg=colour240] #{session_name} #[default]#[fg=colour245] #(df -h / --output=avail | paste -sd : -) '
set -g status-right-length 50
# {{{1 loud or quiet?
set-option -g bell-action none
set-option -g visual-activity off
set-option -g visual-bell off
set-option -g visual-silence off
setw -g clock-mode-colour colour135
# {{{1 mode
setw -g mode-style bold
setw -ag mode-style bg=colour238
setw -ag mode-style fg=colour196
# {{{1 window
setw -g window-status-style none
setw -ag window-status-style bg=colour235
setw -g window-status-bell-style bg=colour1
setw -ag window-status-bell-style bold
setw -ag window-status-bell-style fg=colour255
setw -g window-status-current-style bg=colour238
setw -ag window-status-current-style bold
setw -ag window-status-current-style fg=colour81
setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
setw -g window-status-style fg=colour138
setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
set-window-option -g monitor-activity off
# {{{1 modeline
# vim:ft=tmux:fdm=marker
