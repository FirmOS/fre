#!/bin/sh


export FOS_PRODUCT_BUILD_HASH="$(bash ../../firmosdev/fos_buildtools/git_versions.sh)"
export FOS_PRODUCT_MAJOR_VERSION=0
export FOS_PRODUCT_MINOR_VERSION=8
export FOS_PRODUCT_BUILD_NUMBER=LOCALTEST

printf "$FOS_PRODUCT_BUILD_HASH"
echo
echo "core"
cd ../../core/fos_buildtools
./clean_all.sh
./matrix_build.sh $1
echo "hal" 
cd ../../hal/fos_buildtools
./matrix_build.sh $1
echo "artemes"
cd ../../artemes/fos_buildtools
./matrix_build.sh $1
echo "firmbox"
cd ../../firmbox/fos_buildtools
./matrix_build.sh $1
echo "citycom"
cd ../../citycom/fos_buildtools
./matrix_build.sh $1
echo "monsys"
cd ../../monsys/fos_buildtools
./matrix_build.sh $1
echo "firmosdev"
cd ../../firmosdev/fos_buildtools
./matrix_build.sh $1
