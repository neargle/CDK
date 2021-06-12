set -x

last_tag=`git for-each-ref --sort='-authordate' --format="%(refname:short)" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+" | sed -n 1p`
previous_tag=`git for-each-ref --sort='-authordate' --format="%(refname:short)" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | sed -n 2p`

exploit=`git log "${last_tag}...${previous_tag}" --pretty=format:%s -- "pkg/exploit/" | grep -viE ^merge`
evaluate=`git log "${last_tag}...${previous_tag}" --pretty=format:%s -- "pkg/evaluate/" | grep -viE ^merge`
tool=`git log "${last_tag}...${previous_tag}" --pretty=format:%s -- "pkg/tool/" | grep -viE ^merge`

add_before=`echo "$exploit\n$evaluate\n$tool" | uniq`
all_commit_message=`git log "${last_tag}...${previous_tag}" --pretty=format:%s | grep -viE ^merge`

other=`diff -u <(echo "$add_before") <(echo "$all_commit_message") | grep -E "^\+[a-zA-Z]" | cut -c 2-`

exploit=`echo "$exploit" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'`
evaluate=`echo "$evaluate" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'`
tool=`echo "$tool" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'`

[[ $exploit = *[^[:space:]]* ]] && exploit=$'### Exploits\n\n'"$exploit"
[[ $evaluate = *[^[:space:]]* ]] && evaluate=$'### About Evaluate\n\n'"${evaluate}"
[[ $tool = *[^[:space:]]* ]] && tool=$'### Tools\n\n'"${tool}"

release_body=$(cat <<- EOF
Release Date: $date_string

## Changelog:

$exploit

$evaluate

$tool

## Hash Table

|sha256|exectue file|
|---|---|
|$sha256_text_body|
EOF
)

echo "$release_body" > /tmp/cl.md
