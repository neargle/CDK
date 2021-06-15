set -x

TAG_VERSION=`echo "$GITHUB_REF" | sed -e 's/refs\/tags\///'`

LAST_TAG="$TAG_VERSION"
PREVIOUS_TAG=`git for-each-ref --sort='-authordate' --format="%(refname:short)" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$" | sed -n 2p`

exploit=`git log "${LAST_TAG}...${PREVIOUS_TAG}" --pretty=format:%s -- "pkg/exploit/" | grep -viE ^merge` || :
evaluate=`git log "${LAST_TAG}...${PREVIOUS_TAG}" --pretty=format:%s -- "pkg/evaluate/" | grep -viE ^merge` || :
tool=`git log "${LAST_TAG}...${PREVIOUS_TAG}" --pretty=format:%s -- "pkg/tool/" | grep -viE ^merge` || :

add_before=`echo "$exploit\n$evaluate\n$tool" | uniq`
all_commit_message=`git log "${LAST_TAG}...${PREVIOUS_TAG}" --pretty=format:%s | grep -viE ^merge` || :
other=`diff -u <(echo "$add_before") <(echo "$all_commit_message") | grep -E "^\+[a-zA-Z]" | cut -c 2-` || :

[[ $exploit = *[^[:space:]]* ]] && exploit=`echo "$exploit" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'` && exploit=$'### Exploits\n\n'"$exploit"
[[ $evaluate = *[^[:space:]]* ]] && evaluate=`echo "$evaluate" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'` && evaluate=$'### About Evaluate\n\n'"${evaluate}"
[[ $tool = *[^[:space:]]* ]] && tool=`echo "$tool" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'` && tool=$'### Tools\n\n'"${tool}"
[[ $other = *[^[:space:]]* ]] && other=`echo "$other" | awk '{print toupper(substr($0,1,1))""substr($0,2)}' | sed -e 's/^/* /'` && other=$'### Others\n\n'"${other}"

RELEASE_BODY=$(cat <<- EOF
Release Date: $DATE_STRING

## Changelog:

$exploit

$evaluate

$tool

$other

## Hash Table

|SHA256|EXECTUE FILE|
|---|---|
|$SHA256_TEXT_BODY|
EOF
)

TITLE="CDK $TAG_VERSION"
UPLOAD_URL=$(echo -n $UPLOAD_URL | sed s/\{.*//g)

echo "$RELEASE_BODY" > /tmp/cl.md
