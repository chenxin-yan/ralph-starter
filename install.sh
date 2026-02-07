#!/usr/bin/env bash
# =============================================================================
# Ralph Starter — Install & Update Script
# =============================================================================
# Install:
#   curl -fsSL https://raw.githubusercontent.com/chenxin-yan/ralph-starter/main/install.sh | bash
#
# Update:
#   curl -fsSL https://raw.githubusercontent.com/chenxin-yan/ralph-starter/main/install.sh | bash -s -- --update
#
# Run this from the root of your existing project. It will:
#   1. Check prerequisites (git, jq)
#   2. Clone ralph-starter into a .ralph/ subdirectory (or update existing)
#   3. Symlink skills to .claude/skills/ for Claude Code CLI
#   4. Clean up installer artifacts
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------
RALPH_REPO="https://github.com/chenxin-yan/ralph-starter.git"
RALPH_DIR=".ralph"
CLAUDE_SKILLS_DIR=".claude/skills"

# Framework files that get updated (safe to overwrite)
FRAMEWORK_FILES=(
  "start.sh"
  "PROMPT.md"
  "LICENSE"
  "README.md"
)

# User files that are NEVER overwritten during update
USER_FILES=(
  "config"
  "SPEC.md"
  "prd.json"
  "progress.md"
  "ralph.log"
)

# -----------------------------------------------------------------------------
# Parse Arguments
# -----------------------------------------------------------------------------
UPDATE_MODE=false
for arg in "$@"; do
  case "$arg" in
    --update) UPDATE_MODE=true ;;
    --help|-h)
      printf "Usage:\n"
      printf "  Install:  curl -fsSL <url> | bash\n"
      printf "  Update:   curl -fsSL <url> | bash -s -- --update\n"
      exit 0
      ;;
    *)
      printf "Unknown option: %s\n" "$arg" >&2
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Colors (disabled when not outputting to a terminal)
# -----------------------------------------------------------------------------
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  DIM='\033[2m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' DIM='' RESET=''
fi

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
info()    { printf "${BLUE}${BOLD}i${RESET} %s\n" "$*"; }
success() { printf "${GREEN}${BOLD}✓${RESET} %s\n" "$*"; }
warn()    { printf "${YELLOW}${BOLD}!${RESET} %s\n" "$*"; }
error()   { printf "${RED}${BOLD}✗${RESET} %s\n" "$*" >&2; }
step()    { printf "\n${BOLD}%s${RESET}\n" "$*"; }

die() {
  error "$@"
  exit 1
}

# -----------------------------------------------------------------------------
# Step 1: Prerequisite Checks
# -----------------------------------------------------------------------------
step "Checking prerequisites..."

# Check git
if ! command -v git &>/dev/null; then
  die "git is not installed."
fi
success "git found"

# Check jq
if ! command -v jq &>/dev/null; then
  error "jq is not installed."
  exit 1
fi
success "jq found"

# Check for AI coding CLI (non-blocking warning)
if command -v claude &>/dev/null; then
  success "claude CLI found"
elif command -v opencode &>/dev/null; then
  success "opencode CLI found"
else
  warn "No AI coding CLI detected (claude, opencode)."
  printf "  Ralph requires an AI coding CLI to run. Install one of:\n"
  printf "    ${DIM}Claude Code:  https://docs.anthropic.com/en/docs/claude-code${RESET}\n"
  printf "    ${DIM}OpenCode:     https://github.com/opencode-ai/opencode${RESET}\n"
  printf "    ${DIM}Aider:        https://aider.chat/${RESET}\n"
fi

# =============================================================================
# UPDATE MODE
# =============================================================================
if [ "$UPDATE_MODE" = true ]; then

  if [ ! -d "$RALPH_DIR" ]; then
    die "No '${RALPH_DIR}/' directory found. Run without --update to install first."
  fi

  step "Updating Ralph..."

  # Clone to a temporary directory
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT

  info "Fetching latest ralph-starter..."
  if ! git clone --quiet "$RALPH_REPO" "$TMP_DIR/ralph-latest"; then
    die "Failed to clone ralph-starter. Check your internet connection and try again."
  fi

  # Update framework files
  for file in "${FRAMEWORK_FILES[@]}"; do
    if [ -f "$TMP_DIR/ralph-latest/$file" ]; then
      cp "$TMP_DIR/ralph-latest/$file" "${RALPH_DIR}/$file"
      success "Updated: $file"
    fi
  done

  # Update skills directory (replace entirely — these are framework files)
  if [ -d "$TMP_DIR/ralph-latest/skills" ]; then
    rm -rf "${RALPH_DIR}/skills"
    cp -r "$TMP_DIR/ralph-latest/skills" "${RALPH_DIR}/skills"
    success "Updated: skills/"
  fi

  # Report preserved files
  info "Preserved user files:"
  for file in "${USER_FILES[@]}"; do
    if [ -f "${RALPH_DIR}/$file" ]; then
      printf "    ${DIM}${RALPH_DIR}/${file}${RESET}\n"
    fi
  done

  # Re-link skills (in case new skills were added)
  step "Re-linking skills..."

  SKILLS_SRC="${RALPH_DIR}/skills"
  if [ -d "$SKILLS_SRC" ]; then
    skills_linked=0
    for skill_dir in "$SKILLS_SRC"/*/; do
      skill_name=$(basename "$skill_dir")
      skill_file="${skill_dir}SKILL.md"

      if [ -f "$skill_file" ]; then
        target_dir="${CLAUDE_SKILLS_DIR}/${skill_name}"
        mkdir -p "$target_dir"
        ln -sf "../../../${RALPH_DIR}/skills/${skill_name}/SKILL.md" "${target_dir}/SKILL.md"
        success "Linked skill: ${skill_name}"
        skills_linked=$((skills_linked + 1))
      fi
    done
  fi

  # Success summary
  printf "\n"
  printf "${GREEN}${BOLD}══════════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}  Ralph updated successfully!${RESET}\n"
  printf "${GREEN}${BOLD}══════════════════════════════════════════════${RESET}\n"
  printf "\n"
  printf "  ${BOLD}Updated:${RESET}    start.sh, PROMPT.md, skills/\n"
  printf "  ${BOLD}Preserved:${RESET}  config, SPEC.md, prd.json, progress.md\n"
  printf "\n"

  exit 0
fi

# =============================================================================
# INSTALL MODE (default)
# =============================================================================

step "Installing Ralph..."

if [ -d "$RALPH_DIR" ]; then
  die "A '${RALPH_DIR}/' directory already exists. Ralph may already be set up. Use --update to update."
fi

info "Cloning ralph-starter into ${RALPH_DIR}/..."
if ! git clone --quiet "$RALPH_REPO" "$RALPH_DIR"; then
  die "Failed to clone ralph-starter. Check your internet connection and try again."
fi

# Remove Ralph's own git history
rm -rf "${RALPH_DIR}/.git"
success "Ralph cloned into ${RALPH_DIR}/"

# -----------------------------------------------------------------------------
# Symlink Skills to .claude/skills/
# -----------------------------------------------------------------------------
step "Setting up skills..."

SKILLS_SRC="${RALPH_DIR}/skills"

if [ -d "$SKILLS_SRC" ]; then
  skills_linked=0
  for skill_dir in "$SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"

    if [ -f "$skill_file" ]; then
      target_dir="${CLAUDE_SKILLS_DIR}/${skill_name}"
      mkdir -p "$target_dir"
      ln -sf "../../../${RALPH_DIR}/skills/${skill_name}/SKILL.md" "${target_dir}/SKILL.md"
      success "Linked skill: ${skill_name}"
      skills_linked=$((skills_linked + 1))
    fi
  done

  if [ "$skills_linked" -eq 0 ]; then
    warn "No skills found in ${SKILLS_SRC}/"
  fi
else
  warn "Skills directory not found — skipping skill setup."
fi

# -----------------------------------------------------------------------------
# Clean Up
# -----------------------------------------------------------------------------
rm -f "${RALPH_DIR}/install.sh"

# -----------------------------------------------------------------------------
# Success Summary
# -----------------------------------------------------------------------------
printf "\n"
printf "${GREEN}${BOLD}══════════════════════════════════════════════${RESET}\n"
printf "${GREEN}${BOLD}  Ralph installed successfully!${RESET}\n"
printf "${GREEN}${BOLD}══════════════════════════════════════════════${RESET}\n"
printf "\n"
printf "  ${BOLD}Created:${RESET}\n"
printf "    ${DIM}.ralph/${RESET}             Ralph configuration directory\n"
printf "    ${DIM}.claude/skills/${RESET}     Skills symlinked for Claude Code CLI\n"
printf "\n"
printf "  ${BOLD}Next steps:${RESET}\n"
printf "    1. Write your project spec:     ${BOLD}.ralph/SPEC.md${RESET}\n"
printf "    2. Create your task list:        ${BOLD}.ralph/prd.json${RESET}\n"
printf "    3. Run Ralph:                    ${BOLD}./.ralph/start.sh${RESET}\n"
printf "\n"
printf "  ${DIM}Tip: Use ${RESET}${BOLD}/create-spec${RESET}${DIM} and ${RESET}${BOLD}/create-prd${RESET}${DIM} skills in Claude Code${RESET}\n"
printf "  ${DIM}to help set up your project.${RESET}\n"
printf "\n"
