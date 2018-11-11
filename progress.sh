#!/usr/bin/env bash

IFS=$'\n'

git stash save progress.sh

# Create list of times
times="$(git log | grep -E -i -w -oh 'Date: (.+?)$')"
times=($times)

# Create list of commits
commits="$(git log | grep -E -i -w -oh '[a-f0-9]{40}$')"
commits=($commits)

# Create list of commit messages
messages="$(git log | grep -E -i -w -oh '    (.+?)$')"
messages=($messages)

counts=()
for i in "${!commits[@]}"; do
  `git checkout "${commits[i]}" --quiet`
  counts+=("$(texcount *.tex 2> /dev/null | grep -E -o -i -w 'in text\: (.+)' | tail -1 | cut -d ' ' -f 3)")
done

`git checkout "${commits[0]}" --quiet`

for i in "${!commits[@]}"; do
  times[i]="'${times[i]}'"
  messages[i]="\"${messages[i]}\""
done

counts="$( IFS=$','; echo "${counts[*]}" )"
times="$( IFS=$','; echo "${times[*]}" )"
messages="$( IFS=$','; echo "${messages[*]}" )"
sed -i'.bak' -E "s/counts = \[.+\]/counts = [$counts]/" index.html
sed -i'.bak' -E "s/times = \[.+\]/times = [$times]/" index.html
sed -i'.bak' -E "s/messages = \[.+\]/messages = [${messages//\//\\/}]/" index.html
rm *.bak
git checkout master
git checkout stash@{0} -- progress.sh
git stash clear
