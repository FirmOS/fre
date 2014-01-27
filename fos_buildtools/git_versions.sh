GIT_VERSIONS=""

function add_versions(){
  NEW_VERSION="'"$(basename $(pwd))"--->"$(git rev-parse --abbrev-ref HEAD)" "$(git log -1 --format="%H [%ci]")"'"
  if [ "$GIT_VERSIONS" != "" ]; then
    GIT_VERSIONS="$GIT_VERSIONS""+ LineEnding +"
  fi  
  GIT_VERSIONS="$GIT_VERSIONS""$NEW_VERSION"
}

cd ..
cd ../core
add_versions
cd ../hal
add_versions
cd ../artemes
add_versions
cd ../citycom
add_versions
cd ../firmbox
add_versions
cd ../monsys
add_versions
cd ../firmosdev
add_versions
cd fos_buildtools
printf "$GIT_VERSIONS"
