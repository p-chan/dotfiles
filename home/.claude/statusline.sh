#!/usr/bin/env bash
# Claude Code statusline
# Format: currentDir on branchName (#PR1, #PR2) | Model: <model> | Context: <pct>% | 5h: <pct>% (<time>) | 7d: <pct>% (<time>)

# Read JSON input from stdin (if available)
input=$(cat 2>/dev/null || echo '{}')

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
  printf 'Claude Code (jq not found)'
  exit 0
fi

# ANSI color codes
GREEN=$'\033[32m'
BLUE=$'\033[34m'
YELLOW=$'\033[33m'
RESET=$'\033[0m'

# Extract current directory from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)
if [[ -n "$current_dir" && "$current_dir" != "null" ]]; then
  current_dir=$(basename "$current_dir")
else
  current_dir=$(basename "$PWD")
fi

# Get Git branch
git_branch=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git branch --show-current 2>/dev/null)
fi

# Get PR numbers with hyperlinks (requires gh CLI)
pr_numbers=""
if command -v gh >/dev/null 2>&1; then
  repo_url=$(gh repo view --json url -q .url 2>/dev/null)
  if [[ -n "$repo_url" ]]; then
    # Get all PR numbers and format as clickable links
    pr_list=$(gh pr list --head "$(git branch --show-current 2>/dev/null)" --json number -q '.[].number' 2>/dev/null)
    pr_links=""
    while IFS= read -r num; do
      [[ -z "$num" ]] && continue
      # OSC 8 hyperlink format: \033]8;;URL\007text\033]8;;\007
      link=$'\033]8;;'"${repo_url}/pull/${num}"$'\007'"#${num}"$'\033]8;;\007'
      if [[ -n "$pr_links" ]]; then
        pr_links+=", ${link}"
      else
        pr_links="${link}"
      fi
    done <<< "$pr_list"
    pr_numbers="$pr_links"
  fi
fi

# Extract information from JSON
model=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
current_tokens=$(echo "$input" | jq -r '(.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)' 2>/dev/null)

# Get usage limits from API (with caching)
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_DURATION=60  # Cache for 60 seconds

fetch_usage() {
  # Get credentials from macOS keychain
  credentials=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
  if [[ -z "$credentials" ]]; then
    return 1
  fi

  # Extract access token
  access_token=$(echo "$credentials" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
  if [[ -z "$access_token" || "$access_token" == "null" ]]; then
    return 1
  fi

  # Fetch usage from API
  curl -s -H "Authorization: Bearer $access_token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "Accept: application/json" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null
}

# Check cache validity
if [[ -f "$CACHE_FILE" ]]; then
  cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
  if [[ $cache_age -lt $CACHE_DURATION ]]; then
    usage_data=$(cat "$CACHE_FILE")
  fi
fi

# Fetch new data if cache is invalid
if [[ -z "$usage_data" ]]; then
  usage_data=$(fetch_usage)
  if [[ -n "$usage_data" ]]; then
    echo "$usage_data" > "$CACHE_FILE"
  fi
fi

# Extract usage percentages and reset times
five_hour_pct=""
seven_day_pct=""
five_hour_reset=""
seven_day_reset=""
if [[ -n "$usage_data" ]]; then
  five_hour_pct=$(echo "$usage_data" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
  seven_day_pct=$(echo "$usage_data" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
  five_hour_reset=$(echo "$usage_data" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
  seven_day_reset=$(echo "$usage_data" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
fi

# Function to calculate human-readable time until reset
time_until() {
  local reset_time=$1
  if [[ -z "$reset_time" || "$reset_time" == "null" ]]; then
    echo ""
    return
  fi

  # Parse ISO 8601 timestamp and get seconds until reset (UTC)
  local reset_epoch=$(TZ=UTC date -jf "%Y-%m-%dT%H:%M:%S" "${reset_time:0:19}" "+%s" 2>/dev/null)
  if [[ -z "$reset_epoch" ]]; then
    echo ""
    return
  fi

  local now_epoch=$(date +%s)
  local diff=$((reset_epoch - now_epoch))

  if [[ $diff -le 0 ]]; then
    echo ""
    return
  fi

  # Convert to human-readable format
  local days=$((diff / 86400))
  local hours=$(((diff % 86400) / 3600))
  local minutes=$(((diff % 3600) / 60))

  if [[ $days -gt 0 ]]; then
    echo "${days}d"
  elif [[ $hours -gt 0 ]]; then
    echo "${hours}h"
  elif [[ $minutes -gt 0 ]]; then
    echo "${minutes}m"
  else
    echo "<1m"
  fi
}

# Build output parts
output=""

# Directory, branch, and PR (colors match starship.toml)
output+="${YELLOW}${current_dir}${RESET}"
if [[ -n "$git_branch" ]]; then
  output+=" on ${GREEN}${git_branch}${RESET}"
fi
if [[ -n "$pr_numbers" ]]; then
  output+=" ${BLUE}(${pr_numbers})${RESET}"
fi

# Model
if [[ -n "$model" && "$model" != "null" ]]; then
  output+=" | Model: $model"
fi

# Context usage
if [[ -n "$context_size" && -n "$current_tokens" && "$context_size" != "null" && "$current_tokens" != "null" ]]; then
  percent=$((current_tokens * 100 / context_size))
  [[ -n "$output" ]] && output+=" | "
  output+="Context: ${percent}%"
fi

# Usage section
usage_parts=""

# Five hour limit
if [[ -n "$five_hour_pct" && "$five_hour_pct" != "null" ]]; then
  five_hour_int=$(printf "%.0f" "$five_hour_pct" 2>/dev/null || echo "$five_hour_pct")
  usage_parts+="5h: ${five_hour_int}%"

  # Add reset time
  five_hour_time=$(time_until "$five_hour_reset")
  if [[ -n "$five_hour_time" ]]; then
    usage_parts+=" (${five_hour_time})"
  fi
fi

# Seven day limit
if [[ -n "$seven_day_pct" && "$seven_day_pct" != "null" ]]; then
  seven_day_int=$(printf "%.0f" "$seven_day_pct" 2>/dev/null || echo "$seven_day_pct")
  [[ -n "$usage_parts" ]] && usage_parts+=" | "
  usage_parts+="7d: ${seven_day_int}%"

  # Add reset time
  seven_day_time=$(time_until "$seven_day_reset")
  if [[ -n "$seven_day_time" ]]; then
    usage_parts+=" (${seven_day_time})"
  fi
fi

if [[ -n "$usage_parts" ]]; then
  [[ -n "$output" ]] && output+=" | "
  output+="${usage_parts}"
fi

# Fallback if no data available
if [[ -z "$output" ]]; then
  output="Claude Code"
fi

printf '%s' "$output"
