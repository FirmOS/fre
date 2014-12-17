GIT_VERSIONS=""

NEW_VERSION=$(git reflog -1 --format="%d" | sed -e 's/.*tag: //; s/,.*//')
NEW_HASH=$(git log -1 --format="%h [%ci]")
GIT_VERSIONS="$NEW_VERSION"" ""$NEW_HASH"

printf "$GIT_VERSIONS"
