#!/bin/sh
# Claude Code status line:
#   project[/subdir]    branch status    +added -removed    model [⚡] (effort)    context bar pct
# Works with or without Orca: when Orca's status line script exists, the payload
# is forwarded to it so Orca keeps its usage feed. Kept outside
# ~/.orca/agent-hooks/ and referenced by this path in settings.json so Orca
# classifies the slot as user-owned and never overwrites it (see stablyai/orca
# src/main/claude/hook-settings.ts).
# Orca only writes its script while it owns the slot, so on a machine where
# this status line was set before Orca's first run, Orca polls usage instead.
# To restore the feed: drop statusLine from settings.json, start Orca once,
# then run chezmoi apply.

input=$(cat)

orca="$HOME/.orca/agent-hooks/claude-statusline.sh"
[ -r "$orca" ] && printf '%s' "$input" | /bin/sh "$orca" >/dev/null 2>&1

# One jq pass. The context % is derived from current_usage tokens because
# context_window.used_percentage is a rounded integer; formatting stays in jq
# so the decimal separator never depends on the locale. The variables it sets
# start empty, never inherited from the environment if jq fails.
dir='' dir_label='' model='' fast='' effort='' added='' removed='' pct='' tier='' bar=''
eval "$(printf '%s' "$input" | jq -r '
  .context_window as $cw
  | $cw.current_usage as $u
  | (if $u and ($cw.context_window_size // 0) > 0
     then ($u.input_tokens + $u.cache_creation_input_tokens + $u.cache_read_input_tokens)
          * 100 / $cw.context_window_size
     else $cw.used_percentage end) as $pct
  | (if $pct then [($pct / 10 | round), 10] | min else 0 end) as $n
  | (.workspace.current_dir // .cwd // "") as $dir
  | (.workspace.project_dir // "") as $project
  | @sh "dir=\($dir)",
    @sh "dir_label=\(if $project != "" and ($dir | startswith($project + "/"))
                     then ($project | split("/") | last) + "/" + ($dir | ltrimstr($project + "/"))
                     else $dir | split("/") | last end)",
    @sh "model=\(.model.display_name // "")",
    @sh "fast=\(.fast_mode // false)",
    @sh "effort=\(.effort.level // "")",
    @sh "added=\(.cost.total_lines_added // 0)",
    @sh "removed=\(.cost.total_lines_removed // 0)",
    @sh "pct=\(if $pct then ($pct * 10 | round) / 10 | tostring
                            | if contains(".") then . else . + ".0" end
                 else "" end)",
    @sh "tier=\(if $pct == null then "" elif $pct < 50 then "low" elif $pct < 80 then "mid" else "high" end)",
    @sh "bar=\((("█" * $n) // "") + (("░" * (10 - $n)) // ""))"
')"

e=$(printf '\033')
reset="${e}[0m" dim="${e}[2m"
red="${e}[31m" green="${e}[32m" yellow="${e}[33m" magenta="${e}[35m" cyan="${e}[36m"
# Nerd Font nf-oct-git_branch (U+F418), the symbol starship's git_branch uses.
branch_icon=$(printf '\357\220\230')

# One git call: branch, ahead/behind and working-tree counts from porcelain v2.
git_seg=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null | awk \
  -v reset="$reset" -v dim="$dim" -v red="$red" -v green="$green" \
  -v yellow="$yellow" -v magenta="$magenta" -v cyan="$cyan" -v icon="$branch_icon" '
  /^# branch\.oid / { oid = substr($3, 1, 7) }
  /^# branch\.head / { head = $3 }
  /^# branch\.ab / { ahead = substr($3, 2) + 0; behind = substr($4, 2) + 0 }
  /^[12] / { if (substr($2, 1, 1) != ".") staged++; if (substr($2, 2, 1) != ".") modified++ }
  /^u / { conflicts++ }
  /^[?] / { untracked++ }
  END {
    if (head == "") exit
    if (head == "(detached)") head = "(" oid ")"
    s = ""
    if (conflicts) s = s " " red "✗" conflicts reset
    if (staged) s = s " " green "●" staged reset
    if (modified) s = s " " yellow "!" modified reset
    if (untracked) s = s " " dim "?" untracked reset
    if (s == "") s = " " green "✓" reset
    if (ahead) s = s " " cyan "⇡" ahead reset
    if (behind) s = s " " cyan "⇣" behind reset
    printf "%s%s %s%s%s", magenta, icon, head, reset, s
  }')

sep='    '
out="$dir_label"
[ -n "$git_seg" ] && out="$out$sep$git_seg"
if [ "$added" != 0 ] || [ "$removed" != 0 ]; then
  out="$out$sep$green+$added$reset $red-$removed$reset"
fi
out="$out$sep$model"
[ "$fast" = true ] && out="$out $yellow⚡$reset"
[ -n "$effort" ] && out="$out $dim($effort)$reset"
ctx_color=
case "$tier" in
  mid) ctx_color=$yellow ;;
  high) ctx_color=$red ;;
esac
[ -n "$pct" ] && out="$out$sep$ctx_color$bar $pct %$reset"
printf '%s\n' "$out"
