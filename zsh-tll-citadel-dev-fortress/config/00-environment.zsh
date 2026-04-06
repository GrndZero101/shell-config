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
typeset -gr SHELL_FORTRESS_ENV_FILE="${SHELL_FORTRESS_USER_CONFIG_DIR}/env.zsh"
typeset -gr SHELL_FORTRESS_ALIASES_FILE="${SHELL_FORTRESS_USER_CONFIG_DIR}/aliases.zsh"
typeset -gr SHELL_FORTRESS_FUNCTIONS_DIR="${SHELL_FORTRESS_USER_CONFIG_DIR}/functions"
typeset -gr SHELL_FORTRESS_MODULES_DIR="${SHELL_FORTRESS_USER_CONFIG_DIR}/modules"

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

# Load user-owned fortress environment overrides from XDG config.
# Arguments:
#   None.
# Returns:
#   0 when the env file is absent or loads successfully, otherwise 1.
# Side effects:
#   Sources the user env file when it is readable.
fortress-source-user-env() {
  [[ -r "${SHELL_FORTRESS_ENV_FILE}" ]] || return 0

  source "${SHELL_FORTRESS_ENV_FILE}"
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

# Resolve a string startup setting from environment, persistent settings, or fallback.
# Arguments:
#   $1: environment variable name.
#   $2: settings-file variable name.
#   $3: fallback string value.
# Returns:
#   0 after printing the resolved value.
# Side effects:
#   Reads shell parameters by name.
fortress-resolve-string-setting() {
  local env_name="$1"
  local settings_name="$2"
  local fallback="$3"

  if [[ -n "${(P)env_name:-}" ]]; then
    print -r -- "${(P)env_name}"
  elif [[ -n "${(P)settings_name:-}" ]]; then
    print -r -- "${(P)settings_name}"
  else
    print -r -- "${fallback}"
  fi
}

# Resolve the source label for a string startup setting.
# Arguments:
#   $1: environment variable name.
#   $2: settings-file variable name.
# Returns:
#   0 after printing env, persistent, or default.
# Side effects:
#   Reads shell parameters by name.
fortress-resolve-string-setting-source() {
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
    auto|starship|native)
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
#   Reads command availability for supported prompt engines.
fortress-resolve-active-prompt-engine() {
  local configured_engine="$1"

  case "${configured_engine}" in
    auto)
      if (( $+commands[starship] )); then
        print -r -- 'starship'
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

# Return the first editor command available on PATH from the fortress preference list.
# Arguments:
#   None.
# Returns:
#   0 after printing the detected editor command.
# Side effects:
#   Reads command availability on PATH.
fortress-default-editor() {
  local editor_candidate

  for editor_candidate in nvim vim vi nano; do
    if (( $+commands[${editor_candidate}] )); then
      print -r -- "${editor_candidate}"
      return 0
    fi
  done

  print -r -- 'vi'
}

fortress-source-settings || return 1
fortress-source-user-env || return 1

typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_NATIVE_GIT="${SHELL_FORTRESS_ENABLE_NATIVE_GIT-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ZSH_VI_MODE="${SHELL_FORTRESS_ENABLE_ZSH_VI_MODE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ZSH_AUTOCOMPLETE="${SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ZSH_AUTOSUGGESTIONS="${SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_FZF_TAB="${SHELL_FORTRESS_ENABLE_FZF_TAB-}"
typeset -g SHELL_FORTRESS_RAW_ENV_ENABLE_ATUIN="${SHELL_FORTRESS_ENABLE_ATUIN-}"
typeset -g SHELL_FORTRESS_RAW_ENV_PROMPT_ENGINE="${SHELL_FORTRESS_PROMPT_ENGINE-}"
typeset -g SHELL_FORTRESS_RAW_ENV_EDITOR="${EDITOR-}"
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
typeset -g SHELL_FORTRESS_RAW_SETTING_EDITOR="${SHELL_FORTRESS_SETTING_EDITOR-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_HISTSIZE="${SHELL_FORTRESS_SETTING_HISTSIZE-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_SAVEHIST="${SHELL_FORTRESS_SETTING_SAVEHIST-}"
typeset -g SHELL_FORTRESS_RAW_SETTING_KEYTIMEOUT="${SHELL_FORTRESS_SETTING_KEYTIMEOUT-}"

typeset -g SHELL_FORTRESS_SOURCE_HISTSIZE="$(fortress-resolve-integer-setting-source SHELL_FORTRESS_SETTING_HISTSIZE)"
typeset -g SHELL_FORTRESS_SOURCE_SAVEHIST="$(fortress-resolve-integer-setting-source SHELL_FORTRESS_SETTING_SAVEHIST)"
typeset -g SHELL_FORTRESS_SOURCE_KEYTIMEOUT="$(fortress-resolve-integer-setting-source SHELL_FORTRESS_SETTING_KEYTIMEOUT)"
typeset -g SHELL_FORTRESS_SOURCE_PROMPT_ENGINE="$(fortress-resolve-prompt-engine-source SHELL_FORTRESS_PROMPT_ENGINE SHELL_FORTRESS_SETTING_PROMPT_ENGINE)"
typeset -g SHELL_FORTRESS_SOURCE_EDITOR="$(fortress-resolve-string-setting-source EDITOR SHELL_FORTRESS_SETTING_EDITOR)"

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
typeset -g SHELL_FORTRESS_ACTIVE_EDITOR="$(fortress-resolve-string-setting EDITOR SHELL_FORTRESS_SETTING_EDITOR "$(fortress-default-editor)")"

typeset -gi SHELL_FORTRESS_ENABLE_NATIVE_GIT="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_NATIVE_GIT SHELL_FORTRESS_SETTING_ENABLE_NATIVE_GIT 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_VI_MODE="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ZSH_VI_MODE SHELL_FORTRESS_SETTING_ENABLE_ZSH_VI_MODE 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOCOMPLETE 0)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ZSH_AUTOSUGGESTIONS SHELL_FORTRESS_SETTING_ENABLE_ZSH_AUTOSUGGESTIONS 1)"
typeset -gi SHELL_FORTRESS_ENABLE_FZF_TAB="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_FZF_TAB SHELL_FORTRESS_SETTING_ENABLE_FZF_TAB 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ATUIN="$(fortress-resolve-bool-setting SHELL_FORTRESS_ENABLE_ATUIN SHELL_FORTRESS_SETTING_ENABLE_ATUIN 1)"
typeset -gi SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT=0
typeset -gi SHELL_FORTRESS_LOAD_ZSH_AUTOCOMPLETE=0
typeset -g SHELL_PROMPT_MODE='I'
typeset -g SHELL_GIT_PROMPT_EXTRA=''
typeset -ga SHELL_FORTRESS_LOCAL_MODULES
typeset -gA SHELL_FORTRESS_ALIAS_SOURCES
typeset -gA SHELL_FORTRESS_MODULE_ACTIVE_SOURCES
typeset -gA SHELL_FORTRESS_MODULE_ACTIVE_PATHS
typeset -gA SHELL_FORTRESS_MODULE_LOCAL_PATHS
typeset -gA SHELL_FORTRESS_MODULE_CURATED_PATHS

export EDITOR="${SHELL_FORTRESS_ACTIVE_EDITOR}"
export VISUAL="${VISUAL:-${EDITOR}}"

if (( SHELL_FORTRESS_ENABLE_ZSH_VI_MODE )) && (( SHELL_FORTRESS_ENABLE_ZSH_AUTOCOMPLETE )); then
  SHELL_FORTRESS_ENABLE_ZSH_VI_AUTOCOMPLETE_COMPAT=1
fi

if (( SHELL_FORTRESS_ENABLE_ATUIN )); then
  export ATUIN_CONFIG_DIR="${SHELL_PROFILE_ATUIN_CONFIG_DIR}"
  export ATUIN_THEME_DIR="${SHELL_PROFILE_ATUIN_THEME_DIR}"
fi

typeset -g SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/dev-container-fortress/completions/zsh"

typeset -gU path PATH cdpath CDPATH fpath FPATH manpath MANPATH

fpath=(
  "${ZDOTDIR}/functions"
  ${fpath}
)

if [[ -d "${SHELL_FORTRESS_FUNCTIONS_DIR}" ]]; then
  fpath=(
    "${SHELL_FORTRESS_FUNCTIONS_DIR}"
    ${fpath}
  )
fi

if [[ -d "${SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR}" ]]; then
  fpath=(
    "${SHELL_PROFILE_EXTERNAL_ZSH_COMPLETION_DIR}"
    ${fpath}
  )
fi

fpath=(
  "${ZDOTDIR:h}/shared/completions"
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

# Register alias ownership metadata for the active shell.
# Arguments:
#   $1: source label such as core, user, or module:<name>.
#   $@: alias names to mark with that source.
# Returns:
#   0 after updating the alias source table.
# Side effects:
#   Updates SHELL_FORTRESS_ALIAS_SOURCES for aliases that are currently defined.
fortress-register-alias-source() {
  local source_label="$1"
  shift
  local alias_name

  [[ -n "${source_label}" ]] || return 0

  for alias_name in "$@"; do
    [[ -n "${alias_name}" ]] || continue
    if [[ -n "${aliases[${alias_name}]-}" ]]; then
      SHELL_FORTRESS_ALIAS_SOURCES[${alias_name}]="${source_label}"
    fi
  done
}

# Source one user-owned fortress module file when it exists.
# Arguments:
#   $1: module name without extension.
# Returns:
#   0 when absent or loaded successfully, otherwise 1.
# Side effects:
#   Sources the matching module file, falls back to a repo-curated module when
#   available, and prints warnings only when no module source exists.
fortress-source-local-module() {
  local module_name="$1"
  local module_path
  local curated_module_path
  local curated_functions_dir
  local alias_name
  local -A aliases_before aliases_after

  [[ -n "${module_name}" ]] || return 0

  aliases_before=("${(@kv)aliases}")
  module_path="${SHELL_FORTRESS_MODULES_DIR}/${module_name}.zsh"
  curated_module_path="${ZDOTDIR}/curated-modules/${module_name}/module.zsh"
  curated_functions_dir="${ZDOTDIR}/curated-modules/${module_name}/functions"

  if [[ -r "${module_path}" ]]; then
    SHELL_FORTRESS_MODULE_LOCAL_PATHS[${module_name}]="${module_path}"
  else
    unset "SHELL_FORTRESS_MODULE_LOCAL_PATHS[${module_name}]"
  fi

  if [[ -r "${curated_module_path}" ]]; then
    SHELL_FORTRESS_MODULE_CURATED_PATHS[${module_name}]="${curated_module_path}"
  else
    unset "SHELL_FORTRESS_MODULE_CURATED_PATHS[${module_name}]"
  fi

  if [[ -r "${module_path}" ]]; then
    if [[ -r "${curated_module_path}" ]]; then
      SHELL_FORTRESS_MODULE_ACTIVE_SOURCES[${module_name}]='local-fork'
    else
      SHELL_FORTRESS_MODULE_ACTIVE_SOURCES[${module_name}]='local-only'
    fi
    SHELL_FORTRESS_MODULE_ACTIVE_PATHS[${module_name}]="${module_path}"
    source "${module_path}"
    aliases_after=("${(@kv)aliases}")
    for alias_name in ${(@k)aliases_after}; do
      if [[ "${aliases_before[${alias_name}]-}" != "${aliases_after[${alias_name}]}" ]]; then
        SHELL_FORTRESS_ALIAS_SOURCES[${alias_name}]="module:${module_name}"
      fi
    done
    return 0
  fi

  if [[ -r "${curated_module_path}" ]]; then
    SHELL_FORTRESS_MODULE_ACTIVE_SOURCES[${module_name}]='curated'
    SHELL_FORTRESS_MODULE_ACTIVE_PATHS[${module_name}]="${curated_module_path}"
    if [[ -d "${curated_functions_dir}" ]]; then
      fpath=(
        "${curated_functions_dir}"
        ${fpath}
      )
    fi
    source "${curated_module_path}"
    aliases_after=("${(@kv)aliases}")
    for alias_name in ${(@k)aliases_after}; do
      if [[ "${aliases_before[${alias_name}]-}" != "${aliases_after[${alias_name}]}" ]]; then
        SHELL_FORTRESS_ALIAS_SOURCES[${alias_name}]="module:${module_name}"
      fi
    done
    return 0
  fi

  SHELL_FORTRESS_MODULE_ACTIVE_SOURCES[${module_name}]='missing'
  unset "SHELL_FORTRESS_MODULE_ACTIVE_PATHS[${module_name}]"
  print -u2 -r -- "fortress: local module '${module_name}' not found at ${module_path}"
  return 1
}

# Source each enabled user-owned fortress module.
# Arguments:
#   None.
# Returns:
#   0 when every requested module loads successfully, otherwise 1.
# Side effects:
#   Sources user-local module files from the XDG config tree.
fortress-source-local-modules() {
  local module_name
  local load_status=0

  for module_name in "${SHELL_FORTRESS_LOCAL_MODULES[@]}"; do
    fortress-source-local-module "${module_name}" || load_status=1
  done

  return "${load_status}"
}

# Source the user-local aliases file when it exists.
# Arguments:
#   None.
# Returns:
#   0 when absent or loaded successfully, otherwise 1.
# Side effects:
#   Sources the XDG user aliases file.
fortress-source-user-aliases() {
  local alias_name
  local -A aliases_before aliases_after

  [[ -r "${SHELL_FORTRESS_ALIASES_FILE}" ]] || return 0

  aliases_before=("${(@kv)aliases}")
  source "${SHELL_FORTRESS_ALIASES_FILE}"
  aliases_after=("${(@kv)aliases}")

  for alias_name in ${(@k)aliases_after}; do
    if [[ "${aliases_before[${alias_name}]-}" != "${aliases_after[${alias_name}]}" ]]; then
      SHELL_FORTRESS_ALIAS_SOURCES[${alias_name}]='user'
    fi
  done
}
