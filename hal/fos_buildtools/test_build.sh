#!/bin/sh

FOS_PRODUCT_MAJOR_VERSION=47  ; export FOS_PRODUCT_MAJOR_VERSION
FOS_PRODUCT_MINOR_VERSION=11  ; export FOS_PRODUCT_MINOR_VERSION
FOS_PRODUCT_BUILD_NUMBER=99   ; export FOS_PRODUCT_BUILD_NUMBER
FOS_PRODUCT_BUILD_HASH='#tst' ; export FOS_PRODUCT_BUILD_HASH
./param_build.sh 
exit 0