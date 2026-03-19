# Citadel environment and profile-local directory layout.
# Keep startup inputs profile-local and XDG-aligned.

typeset -gr SHELL_PROFILE_STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/shell-config/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_PROFILE_RUNTIME_BASE="${${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}%/}"
typeset -gr SHELL_PROFILE_RUNTIME_DIR="${SHELL_PROFILE_RUNTIME_BASE}/shell-config-${UID:-$(id -u)}/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_SHARED_STATE_DIR="${XDG_STATE_HOME:-${HOME}/.local/state}/shell-config/shared"
typeset -gr SHELL_PROFILE_ZINIT_ROOT="${SHELL_PROFILE_DATA_DIR}/zinit"
typeset -gr SHELL_PROFILE_ZINIT_HOME="${SHELL_PROFILE_DATA_DIR}/zinit/zinit.git"
typeset -gr SHELL_PROFILE_ATUIN_CONFIG_DIR="${ZDOTDIR}/config/atuin"
typeset -gr SHELL_PROFILE_ATUIN_THEME_DIR="${SHELL_PROFILE_ATUIN_CONFIG_DIR}/themes"
typeset -gr SHELL_FORTRESS_USER_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/shell-config.local/${SHELL_PROFILE_NAME}"
typeset -gr SHELL_FORTRESS_SETTINGS_FILE="${SHELL_FORTRESS_USER_CONFIG_DIR}/settings.zsh"
typeset -gr SHELL_FORTRESS_SETTINGS_TEMPLATE="${ZDOTDIR}/config/settings.example.zsh"

mkdir -p -- \
  "${SHELL_PROFILE_STATE_DIR}" \
  "${SHELL_PROFILE_CACHE_DIR}" \
  "${SHELL_PROFILE_DATA_DIR}" \
  "${SHELL_PROFILE_RUNTIME_DIR}"

# Load user-owned fortress startup settings from XDG config.
# Arguments:
#   None.
# Returns:
#   0 when the settings file is absent or loads successfully, otherwise 1.
# Side effects:
#   Sources the user settings file when it is readable.
fortress-source-settings() {
  [[ -r "${SHELL_FORTRESS_SETTINGS_FILE}" ]] || return 0

  source "${SHELL_FORTRESS_SETTINGS_FILE}"
}

# Resolve a boolean startup toggle from environment, persistent settings, or fallback.
# Arguments:
#   $1: environment variable name.
#   $2: settings-file variable name.
#   $3: fallback numeric value.
# Returns:
#   0 after printing 0 or 1.
# Side effects:
#   Prints a warning to stderr when the value is invalid.
fortress-resolve-bool-setting() {
  local env_name="$1"
  local settings_name="$2"
  local fallback="$3"
  local raw_value

  if [[ -n "${(P)env_name:-}" ]]; then
    raw_value="${(P)env_name}"
  elif [[ -n "${(P)settings_name:-}" ]]; then
    raw_value="${(P)settings_name}"
  else
    raw_value="${fallback}"
  fi

  case "${raw_value:l}" in
    1|true|yes|on)
      print -r -- 1
      ;;
    0|false|no|off)
      print -r -- 0
      ;;
    *)
      print -u2 -r -- "fortress: invalid boolean value '${raw_value}' for ${env_name}; using ${fallback}"
      print -r -- "${fallback}"
      ;;
  esac
}

# Resolve the source label for a boolean startup toggle.
# Arguments:
#   $1: environment variable name.
#   $2: settings-file variable name.
# Returns:
#   0 after printing env, persistent, or default.
# Side effects:
#   Reads shell parameters by name.
fortress-resolve-bool-setting-source() {
  local env_name="$1"
  local settings_name="$2"

  if [[ -n "${(P)env_name:-}" ]]; then
    print -r -- 'env'
  elif [[ -n "${(P)settings_name:-}" ]]; then
    print -r -- 'persistent'
  else
    print -r -- 'default'
  fi
}

# Resolve a numeric startup setting from persistent settings or fallback.
# Arguments:
#   $1: settings-file variable name.
#   $2: fallback integer value.
# Returns:
#   0 after printing the resolved integer.
# Side effects:
#   Prints a warning to stderr when the value is invalid.
fortress-resolve-integer-setting() {
  local settings_name="$1"
  local fallback="$2"
  local raw_value

  if [[ -n "${(P)settings_name:-}" ]]; then
    raw_value="${(P)settings_name}"
  else
    raw_value="${fallback}"
  fi

  if [[ "${raw_value}" == <-> ]]; then
    print -r -- "${raw_value}"
    return 0
  fi

  print -u2 -r -- "fortress: invalid integer value '${raw_value}' for ${settings_name}; using ${fallback}"
  print -r -- "${fallback}"
}

# Resolve the source label for a numeric startup setting.
# Arguments:
#   $1: settings-file variable name.
# Returns:
#   0 after printing persistent or default.
# Side effects:
#   Reads shell parameters by name.
fortress-resolve-integer-setting-source() {
  local settings_name="$1"

  if [[ -n "${(P)settings_name:-}" ]]; then
    print -r -- 'persistent'
  else
    print -r -- 'default'
  fi
}

# Resolve a prompt-engine setting from environment, persistent settings, or fallback.
# Arguments:
#   $1: environment variable name.
#   $2: settings-file variable name.
#   $3: fallback engine name.
# Returns:
#   0 after printing the resolved engine value.
# Side effects:
#   Prints a warning to stderr when the value is invalid.
fortress-resolve-prompt-engine() {
  local env_name="$1"
  local settings_name="$2"
  local fallback="$3"
  local raw_value

  if [[ -n "${(P)env_name:-}" ]]; then
    raw_value="${(P)env_name}"
  elif [[ -n "${(P)settings_name:-}" ]]; then
    raw_value="${(P)settings_name}"
  else
    raw_value="${fallback}"
  fi

  case "${raw_value}" in
    auto|oh-my-posh|starship|native)
      print -r -- "${raw_value}"
      ;;
    *)
      print -u2 -r -- "fortress: invalid prompt engine '${raw_value}' for ${env_name}; using ${fallback}"
      print -r -- "${fallback}"
      ;;
  esac
}

# Resolve the source label for a prompt-engine setting.
# Arguments:
#   $1: environment variable name.
#   $2: settings-file variable name.
# Returns:
#   0 after printing env, persistent, or default.
# Side effects:
#   Reads shell parameters by name.
fortress-resolve-prompt-engine-source() {
  local env_name="$1"
  local settings_name="$2"

  if [[ -n "${(P)env_name:-}" ]]; then
    print -r -- 'env'
  elif [[ -n "${(P)settings_name:-}" ]]; then
    print -r -- 'persistent'
  else
    print -r -- 'default'
  fi
}

# Resolve the active prompt engine after availability checks.
# Arguments:
#   $1: configured engine value.
# Returns:
#   0 after printing the resolved engine value.
# Side effects:
#   Reads command availability for oh-my-posh and starship.
fortress-resolve-active-prompt-engine() {
  local configured_engine="$1"

  case "${configured_engine}" in
    auto)
      if (( $+commands[oh-my-posh] )); then
        print -r -- 'oh-my-posh'
      elif (( $+commands[starship] )); then
        print -r -- 'starship'
      else
        print -r -- 'native'
      fi
      ;;
    oh-my-posh)
      if (( $+commands[oh-my-posh] )); then
        print -r -- 'oh-my-posh'
      else
        print -r -- 'native'
      fi
      ;;
    starship)
      if (( $+commands[starship] )); then
        print -r -- 'starship'
      else
        print -r -- 'native'
      fi
      ;;
    native)
      print -r -- 'native'
      ;;
  esac
}

fortress-source-settings || return 1

typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_NATIVE_GIT="${SHELL_FORTRESS_ENABLE_NATIVE_GIT-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ZSH_VI_MODE="${SHELL_FORTRESS_ENABLE_ZSH_VI_MODE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ZSH_AUTOCOMPLETE="${SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ZSH_AUTOSUGGESTIONS="${SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_FZF_TAB="${SHELL_FORTRESS_ENABLE_FZF_TAB-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ATUIN="${SHELL_FORTRESS_ENABLE_ATUIN-}"
typeset -g SHELL_FORTRESS_RAW_ENV_PROMPT_ENGINE="${SHELL_FORTRESS_PROMPT_ENGINE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_HISTSIZE="${HISTSIZE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_SAVEHIST="${SAVEHIST-}"
typeset -g SHELL_FORTRESS_RAW_ENV_KEYTIMEOUT="${KEYTIMEOUT-}"

typeset -g SHELL_FORTRESS_RAW_SETTING_ENABLE_NATIVE_GIT="${SHELL_FORTRESS_SETTING_ENABLE_NATIVE_GIT-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_ENABLE_ZSH_VI_MODE="${SHELL_FORTRESS_SETTING_ENABLE_ZSH_VI_MODE-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_ENABLE_ZSH_AUTOCOMPLETE="${SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOCOMPLETE-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS="${SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_ENABLE_FZF_TAB="${SHELL_FORTRESS_SETTING_ENABLE_FZF_TAB-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_ENABLE_ATUIN="${SHELL_FORTRESS_SETTING_ENABLE_ATUIN-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_PROMPT_ENGINE="${SHELL_FORTRESS_SETTING_PROMPT_ENGINE-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_HISTSIZE="${SHELL_FORTRESS_SETTING_HISTSIZE-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_SAVEHIST="${SHELL_FORTRESS_SETTING_SAVEHIST-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_KEYTIMEOUT="${SHELL_FORTRESS_SETTING_KEYTIMEOUT-}"

typeset -g SHELL_FORTRESS_SOURCE_HISTSIZE="$(fortress-resolve-integer-setting-source SHELL_FORTRESS_SETTING_HISTSIZE)"
typeset -g SHELL_FORTRESS_SOURCE_SAVEHIST="$(fortress-resolve-integer-setting-source SHELL_FORTRESS_SETTING_SAVEHIST)"
typeset -g SHELL_FORTRESS_SOURCE_KEYTIMEOUT="$(fortress-resolve-integer-setting-source SHELL_FORTRESS_SETTING_KEYTIMEOUT)"
typeset -g SHELL_FORTRESS_SOURCE_PROMPT_ENGINE="$(fortress-resolve-prompt-engine-source SHELL_FORTRESS_PROMPT_ENGINE SHELL_FORTRESS_SETTING_PROMPT_ENGINE)"

typeset -gi HISTSIZE="$(fortress-resolve-integer-setting SHELL_FORTRESS_SETTING_HISTSIZE 100000)"
typeset -gi SAVEHIST="$(fortress-resolve-integer-setting SHELL_FORTRESS_SETTING_SAVEHIST 100000)"
typeset -gi KEYTIMEOUT="$(fortress-resolve-integer-setting SHELL_FORTRESS_SETTING_KEYTIMEOUT 1)"
export HISTSIZE SAVEHIST KEYTIMEOUT

typeset -g SHELL_FORTRESS_SOURCE_ENABLE_NATIVE_GIT="$(fortress-resolve-bool-setting-source SHELL_FORTRESS_ENABLE_NATIVE_GIT SHELL_FORTRESS_SETTING_ENABLE_NATIVE_GIT)"
typeset -g SHELL_FORTRESS_SOURCE_ENABLE_ZSH_VI_MODE="$(fortress-resolve-bool-setting-source SHELL_FORTRESS_ENABLE_ZSH_VI_MODE SHELL_FORTRESS_SETTING_ENABLE_ZSH_VI_MODE)"
typeset -g SHELL_FORTRESS_SOURCE_ENABLE_ZSH_AUTOCOMPLETE="$(fortress-resolve-bool-setting-source SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOCOMPLETE)"
typeset -g SHELL_FORTRESS_SOURCE_ENABLE_ZSH_AUTOSUGGESTIONS="$(fortress-resolve-bool-setting-source SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS)"
typeset -g SHELL_FORTRESS_SOURCE_ENABLE_FZF_TAB="$(fortress-resolve-bool-setting-source SHELL_FORTRESS_ENABLE_FZF_TAB SHELL_FORTRESS_SETTING_ENABLE_FZF_TAB)"
typeset -g SHELL_FORTRESS_SOURCE_ENABLE_ATUIN="$(fortress-resolve-bool-setting-source SHELL_FORTRESS_ENABLE_ATUIN SHELL_FORTRESS_SETTING_ENABLE_ATUIN)"
typeset -g SHELL_FORTRESS_CONFIGURED_PROMPT_ENGINE="$(fortress-resolve-prompt-engine SHELL_FORTRESS_PROMPT_ENGINE SHELL_FORTRESS_SETTING_PROMPT_ENGINE auto)"
typeset -g SHELL_FORTRESS_ACTIVE_PROMPT_ENGINE="$(fortress-resolve-active-prompt-engine "${SHELL_FORTRESS_CONFIGURED_PROMPT_ENGINE}")"

typeset -gi SHELL_FORTRESS_ENABLE_NATIVE_GIT="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_NATIVE_GIT SHELL_FORTRESS_SETTING_ENABLE_NATIVE_GIT 0)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_VI_MODE="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ZSH_VI_MODE SHELL_FORTRESS_SETTING_ENABLE_ZSH_VI_MODE 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOCOMPLETE 0)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS 1)"
typeset -gi SHELL_FORTRESS_ENABLE_FZF_TAB="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_FZF_TAB SHELL_FORTRESS_SETTING_ENABLE_FZF_TAB 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ATUIN="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ATUIN SHELL_FORTRESS_SETTING_ENABLE_ATUIN 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT=0
typeset -gi SHELL_FORTRESS_LOAD_ZSH_AUTOCOMPLETE=0
typeset -g SHELL_PROMPT_MODE='I'
typeset -g SHELL_GIT_PROMPT_EXTRA=''

if (( SHELL_FORTRESS_ENABLE_ZSH_VI_MODE )) && (( SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE )); then
  SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT=1
fi

if (( SHELL_FORTRESS_ENABLE_ATUIN )); then
  export ATUIN_CONFIG_DIR="${SHELL_PROFILE_ATUIN_CONFIG_DIR}"
  export ATUIN_THEME_DIR="${SHELL_PROFILE_ATUIN_THEME_DIR}"
fi

typeset -gU path PATH cdpath CDPATH fpath FPATH manpath MANPATH

fpath=(
  "${ZDOTDIR:h}/shared/completions"
  "${ZDOTDIR}/functions"
  ${fpath}
)

typeset -a shell_brew_completion_candidates shell_brew_completion_dirs

if (( $+commands[brew] )); then
  shell_brew_completion_candidates=(
    "${commands[brew]:h:h}/share/zsh/site-functions"
    "${commands[brew]:h:h}/share/zsh-completions"
  )
else
  shell_brew_completion_candidates=(
    /opt/homebrew/share/zsh/site-functions
    /opt/homebrew/share/zsh-completions
    /usr/local/share/zsh/site-functions
    /usr/local/share/zsh-completions
    /home/linuxbrew/.linuxbrew/share/zsh/site-functions
    /home/linuxbrew/.linuxbrew/share/zsh-completions
  )
fi

for shell_brew_completion_dir in ${shell_brew_completion_candidates}; do
  [[ -d "${shell_brew_completion_dir}" ]] || continue
  shell_brew_completion_dirs+=("${shell_brew_completion_dir}")
done

fpath=(
  ${shell_brew_completion_dirs}
  ${fpath}
)

unset shell_brew_completion_candidates shell_brew_completion_dir shell_brew_completion_dirs

cdpath=(
  .
  "${HOME}"
  "${HOME}/projects"
  "${HOME}/src"
)

# Bootstrap the profile-local zinit install when it is available.
# Arguments:
#   None.
# Returns:
#   0 when zinit is ready to use, otherwise 1.
# Side effects:
#   Exports zinit cache paths, initializes ZINIT globals, and sources zinit.zsh once.
fortress-bootstrap-zinit() {
  if (( $+functions[zinit] )); then
    return 0
  fi

  [[ -r "${SHELL_PROFILE_ZINIT_HOME}/zinit.zsh" ]] || return 1

  typeset -gAH ZINIT
  export ZSH_CACHE_DIR="${SHELL_PROFILE_CACHE_DIR}/zinit"
  ZINIT[HOME_DIR]="${SHELL_PROFILE_ZINIT_ROOT}"
  ZINIT[BIN_DIR]="${SHELL_PROFILE_ZINIT_HOME}"

  source "${SHELL_PROFILE_ZINIT_HOME}/zinit.zsh"
}
