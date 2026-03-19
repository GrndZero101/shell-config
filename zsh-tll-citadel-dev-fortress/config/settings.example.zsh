# Fortress persistent startup settings template.
# Copy this to ${XDG_CONFIG_HOME:-$HOME/.config}/shell-config.local/zsh-tll-citadel-dev-fortress/settings.zsh
# to make login-time and container-startup defaults persistent for this profile.

# History and editor timing.
SHELL_FORTRESS_SETTING_HISTSIZE=100000
SHELL_FORTRESS_SETTING_SAVEHIST=100000
SHELL_FORTRESS_SETTING_KEYTIMEOUT=1

# Prompt engine selection: auto, oh-my-posh, starship, or native.
SHELL_FORTRESS_SETTING_PROMPT_ENGINE=auto

# Core fortress feature toggles.
SHELL_FORTRESS_SETTING_ENABLE_NATIVE_GIT=0
SHELL_FORTRESS_SETTING_ENABLE_ZSH_VI_MODE=1
SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOCOMPLETE=0
SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS=1
SHELL_FORTRESS_SETTING_ENABLE_FZF_TAB=1
SHELL_FORTRESS_SETTING_ENABLE_ATUIN=1

# Supported boolean values: 1/0, true/false, yes/no, on/off.
# Prompt engine values: auto, oh-my-posh, starship, native.
# Environment variables still win for one-off sessions.
