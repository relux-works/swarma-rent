#!/bin/sh
# Hygiene check for the Swarma Rent book (Russian chapters).
#
#   sh book/check.sh
#
# The rules are those of the Swarma books' style guide. The check fails on:
# internal identifiers (board elements, runs, review findings, decision
# numbers); local paths; a local deny list of names (RENT_BOOK_DENY_FILE);
# retired names; status markers
# and delivery hedges outside the two state chapters; the prose blacklist
# (a dash as a connective, guillemets, antithesis, filler openers, marketing
# adjectives); a chapter without a level-1 heading. Every hit is printed with
# its file and line.
#
# The state chapters are the gap list (NN-chego-ne-hvataet.md) and the status
# chapter (NN-gde-my.md): only they may say what is not built.
#
#   STRICT_PROSE=0 sh book/check.sh   # report blacklist hits, do not fail
#
# The checks are lexical. A dash is any em dash, and any en dash except in a
# numeric range whose left side is a digit. A hedge is "пока", "ещё не" (also
# written "еще не"), "в v0" or "не реализован..."; other wordings of the same
# meaning pass, and the final judgement stays with the reviewer.
set -u

utf8=
for loc in C.UTF-8 en_US.UTF-8 C.utf8 en_US.utf8; do
  if printf 'Пока ё\n' | LC_ALL=$loc grep -qiE '^пока [ё]$' 2>/dev/null; then
    utf8=$loc
    break
  fi
done
[ -n "$utf8" ] || { echo "check.sh: no UTF-8 locale available (tried C.UTF-8, en_US.UTF-8); refusing" >&2; exit 2; }
LC_ALL=$utf8
export LC_ALL

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root" || exit 2

files=$(find ru -type f -name '*.md' 2>/dev/null | sort)
[ -n "$files" ] || { echo "check.sh: nothing to check"; exit 0; }

fail=0
hit() {
  # $1 label, $2 extended regex, $3 optional file list
  out=$(grep -nE -- "$2" ${3:-$files} 2>/dev/null)
  if [ -n "$out" ]; then
    echo "== $1"
    echo "$out"
    fail=1
  fi
}

hit "board, run or review identifier" '\b(TASK|STORY|EPIC|BUG|RUN|SES)-[0-9]{6}-[0-9a-z]{6}\b'
hit "review finding number" '(^|[^A-Za-z0-9-])F-[0-9]{2,3}([^0-9]|$)'
hit "decision number" '(^|[^A-Za-z0-9-])D-0[0-9]{2}([^0-9]|$)'
hit "walk-through item identifier" '(^|[^A-Za-z0-9-])(T[0-9]{1,2}|J[0-9][a-e]?|D(3|15|16)|G[0-9]|PX[0-9])([^A-Za-z0-9]|$)'
hit "local path" '/(Users|home)/[A-Za-z0-9._-]+'
# Machine, seat and people names are not kept in this repository. Point
# RENT_BOOK_DENY_FILE at a local file with one extended regular expression
# per line (lines starting with # are comments); every hit fails the check.
deny_file="${RENT_BOOK_DENY_FILE:-}"
if [ -n "$deny_file" ]; then
  [ -r "$deny_file" ] || { echo "check.sh: deny file $deny_file is not readable; refusing" >&2; exit 2; }
  while IFS= read -r pat; do
    case "$pat" in ''|'#'*) continue ;; esac
    hit "local deny list" "$pat"
  done < "$deny_file"
fi
hit "messenger room or event identifier" '(![A-Za-z0-9_-]{20,}|\$[A-Za-z0-9_-]{8,}|@[a-z0-9._-]+:[a-z0-9.-]+)'
hit "retired name" '([Ss]lopcore|пасек|\bульев?\b|диких? пчёл|Seraph|\bKeymaker\b|\bSwarm (Runtime|Protocol|Chain|Keeper|Curator|Signer)\b)'
hit "the word grant in Russian prose" '(^|[^[:alpha:]])грант[[:alpha:]]*'

state_files=$(find ru -type f \( -name '*-gde-my.md' -o -name '*-chego-ne-hvataet.md' \) 2>/dev/null | sort)
other_files=$(find ru -type f -name '*.md' ! -name '*-gde-my.md' ! -name '*-chego-ne-hvataet.md' 2>/dev/null | sort)

[ -z "$other_files" ] || hit "status marker" '[⟦⟧]' "$other_files"

if [ -n "$other_files" ]; then
  out=$(grep -niE -- '(^|[^[:alpha:]])(пока|[её]щ[её][[:space:]]+не|в[[:space:]]+v0|не[[:space:]]+реализован[[:alpha:]]*)($|[^[:alpha:]])' $other_files 2>/dev/null)
  if [ -n "$out" ]; then
    echo '== delivery hedge'
    echo "$out"
    fail=1
  fi
fi

prose() {
  # $1 label, $2 extended regex (case-insensitive)
  out=$(grep -niE -- "$2" $files 2>/dev/null)
  if [ -n "$out" ]; then
    if [ "${STRICT_PROSE:-1}" = 0 ]; then echo "== $1 (advisory)"; else echo "== $1"; fail=1; fi
    echo "$out"
  fi
}
prose "dash in prose" '—|(^|[^0-9])–|–($|[^[:alnum:]])'
prose "guillemets" '[«»]'
prose "antithesis" '(не[[:space:]]+просто[[:space:]].*,[[:space:]]+а[[:space:]])|(это[[:space:]]+не[[:space:]].*,[[:space:]]+а[[:space:]])|(речь[[:space:]]+не[[:space:]]+о[[:space:]])'
prose "filler opener" '(стоит[[:space:]]+отметить|важно[[:space:]]+понимать|давайте[[:space:]]+разбер|в[[:space:]]+современном[[:space:]]+мире)'
prose "marketing adjective" '(^|[^[:alpha:]])(мощн[[:alpha:]]*|бесшовн[[:alpha:]]*)($|[^[:alpha:]])'

# The letter "ё" is mandatory: the most frequent words that lose it.
prose "missing ё" '(^|[^[:alpha:]])(еще|ее|все-таки|счет|счетом|счете|счету|учет[[:alpha:]]*|отчет[[:alpha:]]*|расчет[[:alpha:]]*|четк[[:alpha:]]*|жестк[[:alpha:]]*|придет|пойдет|найдет|берет|дает|идет|ведет|живет|несет|вернет|начнет|своем|трех|четырех|определен|определенн[[:alpha:]]*|включен|включенн[[:alpha:]]*|закреплен|закрепленн[[:alpha:]]*|разрешен|разрешенн[[:alpha:]]*|запрещен|запрещенн[[:alpha:]]*|подтвержден|подтвержденн[[:alpha:]]*|удален|удаленн[[:alpha:]]*|завершен|завершенн[[:alpha:]]*)($|[^[:alpha:]])'

for f in ru/[0-9][0-9]*.md; do
  [ -e "$f" ] || continue
  n=$(grep -cE '^# ' "$f")
  if [ "$n" -lt 1 ]; then
    echo "== chapter without a level-1 heading: $f"
    fail=1
  fi
done

[ "$fail" -eq 0 ] && echo "check.sh: ok ($(echo "$files" | wc -l | tr -d ' ') files)"
exit "$fail"
