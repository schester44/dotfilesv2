# Unified worktree management command
wt() {
	local cmd="$1"
	shift 2>/dev/null

	case "$cmd" in
		new|n)
			_wt_new "$@"
			;;
		list|ls|l)
			_wt_list "$@"
			;;
		go|g)
			_wt_go "$@"
			;;
		delete|del|d|rm)
			_wt_delete "$@"
			;;
		setup|s)
			_wt_setup "$@"
			;;
		help|--help|-h|"")
			_wt_help
			;;
		*)
			echo "❌ Unknown command: $cmd"
			_wt_help
			return 1
			;;
	esac
}

_wt_help() {
	cat <<EOF
Usage: wt <command> [options]

Commands:
  new, n     <name> [base] [args...]   Create a new worktree
  list, ls, l                          List all worktrees
  go, g      <number|name>             Change to a worktree
  delete, d, rm [number|name]          Delete a worktree (current if no arg)
  setup, s   [args...]                 Run setup script in current worktree

Base branch (optional, defaults to main/master):
  <branch>   Branch off origin/<branch>
  .          Branch off current branch

Examples:
  wt new my-feature
  wt new my-feature develop
  wt new my-feature .
  wt list
  wt go 2
  wt go my-feature
  wt delete
  wt delete my-feature
  wt setup 
EOF
}

_wt_new() {
	local session_name="$1"
	local base_arg="$2"
	shift 2 2>/dev/null || shift 1 2>/dev/null
	local setup_args=("$@")

	if [[ -z "$session_name" ]]; then
		echo "Usage: wt new <name> [base-branch] [setup-args...]"
		echo "Example: wt new my-feature              # branch off main"
		echo "         wt new my-feature develop       # branch off origin/develop"
		echo "         wt new my-feature .             # branch off current branch"
		return 1
	fi

	local repo_root
	if ! repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)"; then
		echo "❌ Not inside a Git repository."
		return 1
	fi

	local repo_name
	repo_name="$(basename "$repo_root")"

	local worktree_base="$HOME/worktrees/$repo_name"

	# Create the worktree directory if it doesn't exist
	if [[ ! -d "$worktree_base" ]]; then
		echo "📁 Creating worktree directory: $worktree_base"
		mkdir -p "$worktree_base"
	fi

	local base_branch
	if [[ -n "$base_arg" ]]; then
		if [[ "$base_arg" == "." ]]; then
			# Use current branch
			base_branch=$(git -C "$repo_root" branch --show-current 2>/dev/null)
			if [[ -z "$base_branch" ]]; then
				echo "❌ Not on a branch (detached HEAD?)."
				return 1
			fi
		else
			base_branch="$base_arg"
		fi
		# Verify the branch exists on origin
		if ! git -C "$repo_root" rev-parse --verify "origin/$base_branch" >/dev/null 2>&1; then
			echo "❌ origin/$base_branch does not exist."
			return 1
		fi
	elif git -C "$repo_root" rev-parse --verify origin/main >/dev/null 2>&1; then
		base_branch="main"
	elif git -C "$repo_root" rev-parse --verify origin/master >/dev/null 2>&1; then
		base_branch="master"
	else
		echo "❌ Neither origin/main nor origin/master exists. Specify a base branch."
		return 1
	fi

	# Replace spaces with dashes for branch name (git doesn't allow spaces in branch names)
	local new_branch="${session_name// /_}"
	local worktree_path="$worktree_base/$session_name"

	echo "📁 Creating worktree from '$base_branch' at: $worktree_path"

	if ! git -C "$repo_root" fetch origin "$base_branch"; then
		echo "❌ Failed to fetch from origin"
		return 1
	fi

	if ! git -C "$repo_root" worktree add -b "$new_branch" "$worktree_path" "origin/$base_branch"; then
		echo "❌ Failed to create worktree (branch may already exist or path is in use)"
		return 1
	fi

	echo "✅ Worktree created at: $worktree_path"
	echo "➡️  Branch: $new_branch"

	# Check for and run setup script if it exists
	local setup_script="$repo_root/.agents/worktree-setup.sh"
	if [[ -f "$setup_script" ]]; then
		echo "🔧 Running worktree setup script..."
		if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$session_name" bash "$setup_script" "${setup_args[@]}"); then
			echo "✅ Setup script completed successfully"
		else
			echo "⚠️  Setup script failed with exit code $?"
		fi
	else
		echo "ℹ️  No setup script found at .agents/worktree-setup.sh"
	fi

	# Open a new WezTerm tab with the task name
	if command -v wezterm &>/dev/null; then
		echo "🪟 Opening new WezTerm tab..."
		local pane_id
		pane_id=$(wezterm cli spawn --cwd "$worktree_path" -- zsh -i -c "e; exec zsh")
		if [[ -n "$pane_id" ]]; then
			wezterm cli set-tab-title --pane-id "$pane_id" "$session_name"
			# Small delay to avoid git config lock contention
			sleep 0.5
			wezterm cli split-pane --right --pane-id "$pane_id" -- zsh -i -c "pi"
		fi
	fi
}

_wt_list() {
	local repo_root
	if ! repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)"; then
		echo "❌ Not inside a Git repository."
		return 1
	fi

	local current_dir
	current_dir="$(pwd)"

	echo "📋 Active Worktrees:"
	echo ""

	local i=1
	local worktree_path
	local branch
	git -C "$repo_root" worktree list | while IFS= read -r line; do
		worktree_path=$(echo "$line" | awk '{print $1}')
		branch=$(echo "$line" | grep -oE '\[.*\]' | tr -d '[]')

		# Skip the main repo worktree (not under worktrees/)
		if [[ ! "$worktree_path" =~ /worktrees/ ]]; then
			continue
		fi

		# Check if this is the current worktree
		if [[ "$current_dir" == "$worktree_path"* ]]; then
			echo "➡️  [$i] $worktree_path ($branch) [current]"
		else
			echo "   [$i] $worktree_path ($branch)"
		fi
		((i++))
	done
}

_wt_go() {
	local input="$1"

	if [[ -z "$input" ]]; then
		echo "❌ Usage: wt go <number|name>"
		return 1
	fi

	local repo_root
	if ! repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)"; then
		echo "❌ Not inside a Git repository."
		return 1
	fi

	local i=1
	local target_path=""
	local worktree_path
	local dir_name

	while IFS= read -r line; do
		worktree_path=$(echo "$line" | awk '{print $1}')

		# Skip the main repo worktree (not under worktrees/)
		if [[ ! "$worktree_path" =~ /worktrees/ ]]; then
			continue
		fi

		# Match by number
		if [[ "$input" =~ ^[0-9]+$ ]] && [[ "$i" -eq "$input" ]]; then
			target_path="$worktree_path"
			break
		fi

		# Match by name (directory name contains input)
		dir_name=$(basename "$worktree_path")
		if [[ "$dir_name" == *"$input"* ]]; then
			target_path="$worktree_path"
			break
		fi

		((i++))
	done < <(git -C "$repo_root" worktree list)

	if [[ -n "$target_path" ]]; then
		cd "$target_path" || return 1
		echo "📂 Changed to: $target_path"
	else
		echo "❌ No worktree found matching: $input"
		return 1
	fi
}

_wt_setup() {
	local setup_args
	setup_args=("$@")

	local worktree_path
	worktree_path="$(pwd)"
	local worktree_name
	worktree_name="$(basename "$worktree_path")"

	# Get the main repo root (not the worktree)
	local git_common_dir
	if ! git_common_dir="$(git rev-parse --git-common-dir 2>/dev/null)"; then
		echo "❌ Not inside a Git repository."
		return 1
	fi
	local repo_root
	repo_root="$(dirname "$git_common_dir")"

	local setup_script="$repo_root/.agents/worktree-setup.sh"
	if [[ -f "$setup_script" ]]; then
		echo "🔧 Running worktree setup script..."
		if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$worktree_name" bash "$setup_script" "${setup_args[@]}"); then
			echo "✅ Setup script completed successfully"
		else
			echo "⚠️  Setup script failed with exit code $?"
			return 1
		fi
	else
		echo "❌ No setup script found at .agents/worktree-setup.sh"
		return 1
	fi
}

_wt_delete() {
	local task_input="$*"

	local repo_root
	if ! repo_root="$(git -C . rev-parse --show-toplevel 2>/dev/null)"; then
		echo "❌ Not inside a Git repository."
		return 1
	fi

	local worktree_path
	local current_dir
	current_dir="$(pwd)"
	local task_name

	# If task input provided, check if it's a number or a name
	if [[ -n "$task_input" ]]; then
		# Check if input is a number
		if [[ "$task_input" =~ ^[0-9]+$ ]]; then
			# Get the task name by index
			local worktrees=("${(@f)$(_wt_get_worktrees "$repo_root")}")
			if (( task_input < 1 || task_input > ${#worktrees[@]} )); then
				echo "❌ Invalid task number: $task_input (valid: 1-${#worktrees[@]})"
				return 1
			fi
			task_name="${worktrees[$task_input]}"
			echo "📌 Selected task: $task_name"
		else
			task_name="$task_input"
		fi

		# Look for worktree matching the task name using --porcelain for reliable parsing
		worktree_path=$(git -C "$repo_root" worktree list --porcelain | awk -v task="$task_name" '
			/^worktree / {
				path = substr($0, 10)
				n = split(path, parts, "/")
				if (parts[n] == task) {
					print path
					exit
				}
			}
		')

		if [[ -z "$worktree_path" ]]; then
			echo "❌ No worktree found with name: $task_name"
			return 1
		fi
	else
		# No argument provided, use current directory
		local git_dir
		git_dir="$(git rev-parse --git-dir 2>/dev/null)"
		if [[ ! "$git_dir" =~ \.git/worktrees ]]; then
			echo "❌ Not inside a git worktree. Provide a task name as argument."
			return 1
		fi
		worktree_path="$current_dir"
	fi

	# Check for and run teardown script if it exists
	local teardown_script="$repo_root/.agents/worktree-teardown.sh"
	local worktree_name
	if [[ -f "$teardown_script" ]]; then
		echo "🔧 Running teardown script..."
		worktree_name=$(basename "$worktree_path")
		if (cd "$worktree_path" && REPO_ROOT="$repo_root" WORKTREE_PATH="$worktree_path" WORKTREE_NAME="$worktree_name" bash "$teardown_script"); then
			echo "✅ Teardown script completed successfully"
		else
			echo "⚠️  Teardown script failed with exit code $?"
			echo "❌ Aborting worktree removal due to teardown failure"
			return 1
		fi
	fi

	# Get the branch name for this worktree before removing it
	local branch_name
	branch_name=$(git -C "$repo_root" worktree list --porcelain | awk -v path="$worktree_path" '
		$1 == "worktree" && $2 == path { capture = 1 }
		capture && $1 == "branch" { sub("refs/heads/", "", $2); print $2; exit }
	')

	# If we're currently in the worktree being removed, move out of it
	if [[ "$current_dir" == "$worktree_path"* ]]; then
		cd ..
	fi

	echo "🗑️  Removing worktree at: $worktree_path"
	if git -C "$repo_root" worktree remove "$worktree_path" --force; then
		echo "✅ Worktree removed successfully"

		# Remove the directory if it still exists
		if [[ -d "$worktree_path" ]]; then
			echo "🗑️  Removing directory: $worktree_path"
			rm -rf "$worktree_path"
		fi

		# Delete the branch if we found one
		if [[ -n "$branch_name" ]]; then
			echo "🗑️  Deleting branch: $branch_name"
			if git -C "$repo_root" branch -D "$branch_name"; then
				echo "✅ Branch deleted successfully"
			else
				echo "⚠️  Failed to delete branch"
			fi
		fi
	else
		echo "⚠️  Failed to remove worktree"
		return 1
	fi
}

# Helper function to get worktree task names (excludes main repo)
_wt_get_worktrees() {
	local repo_root="$1"
	git -C "$repo_root" worktree list --porcelain | awk '
		/^worktree / {
			path = substr($0, 10)
			# Skip the main repo (first worktree is always main)
			if (NR > 1 || path !~ /\.git$/) {
				n = split(path, parts, "/")
				# Only include worktrees under ~/worktrees/
				if (path ~ /\/worktrees\//) {
					print parts[n]
				}
			}
		}
	'
}

# Short aliases
alias tn='wt new'
alias tl='wt list'
alias tg='wt go'
alias td='wt delete'
