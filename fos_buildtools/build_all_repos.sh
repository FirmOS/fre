#!/bin/sh

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
