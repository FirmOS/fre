GIT_VERSIONS=""

function add_versions(){
  NEW_VERSION=$(git rev-parse --abbrev-ref HEAD)" "$(git log -1 --format="%H [%ci]")" ---> "$(basename $(pwd))
  GIT_VERSIONS=$(printf "$GIT_VERSIONS\n$NEW_VERSION")
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
cd ../extra
add_versions
cd ../firmbox
add_versions
cd ../frejs
add_versions
cd ../monsys
add_versions
cd ../firmosdev
add_versions
cd fos_buildtools
printf "$GIT_VERSIONS\n"
