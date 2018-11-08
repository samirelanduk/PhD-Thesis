IFS=$'\n'

# Create directory to go nuts in

# Create list of times
times="$(git log | grep -E -i -w -oh 'Date: (.+?)$')"
times=($times)

# Create list of commits
commits="$(git log | grep -E -i -w -oh '[a-f0-9]{40}$')"
commits=($commits)

counts=()
for i in "${!commits[@]}"; do
  `git checkout "${commits[i]}" --quiet`
  counts+=("$(texcount Thesis.tex | grep -E -i -w -oh 'in text\: (\d+)' | cut -d ' ' -f 3)")
done

`git checkout "${commits[0]}" --quiet`

for i in "${!commits[@]}"; do
  times[i]="'${times[i]}'"
done

counts="$( IFS=$','; echo "${counts[*]}" )"
times="$( IFS=$','; echo "${times[*]}" )"
sed -i'.bak' -E "s/counts = \[.+\]/counts = [$counts]/" index.html
sed -i'.bak' -E "s/times = \[.+\]/times = [$times]/" index.html
rm *.bak
`git checkout master`
