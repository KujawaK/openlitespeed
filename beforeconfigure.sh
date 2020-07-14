#!/bin/sh
### from build.sh
    if [ -e lsquic ] ; then
        ls src/ | grep liblsquic
        if [ $? -eq 0 ] ; then
            echo Need to git download the submodule ...
            rm -rf lsquic
            git clone https://github.com/litespeedtech/lsquic.git
            cd lsquic

            LIBQUICVER=`cat ../LSQUICCOMMIT`
            echo "LIBQUICVER is ${LIBQUICVER}"
            git checkout ${LIBQUICVER}
            git submodule update --init --recursive
            cd ..

            #cp files for autotool
            rm -rf src/liblsquic
            mv lsquic/src/liblsquic src/

            rm -rf src/lshpack
            mv lsquic/src/lshpack src/

            rm include/lsquic.h
            mv lsquic/include/lsquic.h  include/
            rm include/lsquic_types.h
            mv lsquic/include/lsquic_types.h include/

        fi
    fi

STDC_LIB=`g++ -print-file-name='libstdc++.a'`
cp ${STDC_LIB} ../thirdparty/lib64/
cp ../thirdparty/src/brotli/out/*.a          ../thirdparty/lib64/
cp ../thirdparty/src//libxml2/.libs/*.a      ../thirdparty/lib64/
cp ../thirdparty/src/libmaxminddb/include/*  ../thirdparty/include/

if [ "${ISLINUX}" = "yes" ] ; then
    fixPagespeed
fi

#special case modsecurity
cd src/modules/modsecurity-ls
ln -sf ../../../../thirdparty/src/ModSecurity .
cd ../../../
#Done of modsecurity
    if [ ! -d /dev/shm ] ; then
        mkdir /tmp/shm
        chmod 777  /tmp/shm
        sed -i -e "s/\/dev\/shm/\/tmp\/shm/g" dist/conf/httpd_config.conf.in
    fi

###
git submodule update --init --recursive || exit
sed -i 's/LSRECAPTCHA=`. $srcdir\/src\/modules\/lsrecaptcha\/build_lsrecaptcha.sh`/$srcdir\/src\/modules\/lsrecaptcha\/build_lsrecaptcha.sh/g' configure
cp src/lshpack/lshpack.h src/h2/
patch -Np1 -i xxx_header.patch
aclocal || exit
autoconf || exit
automake --add-missing || exit
echo Done
