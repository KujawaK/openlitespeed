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

###
git submodule update --init --recursive || exit
aclocal || exit
autoconf || exit
automake --add-missing || exit
cd include/
ln -s ../src/liblsquic/ls-qpack/lsxpack_header.h lsxpack_header.h
ln -s ../src/liblsquic/ls-qpack/lsqpack.h lsqpack.h
ln -s ../src/lshpack/lshpack.h lshpack.h
ln -s ../ssl/include/openssl/ openssl
cd ..
cp src/lshpack/lshpack.h src/h2/
patch -Np1 -i xxx_header.patch
sed -i 's/BSSL=`. $srcdir\/dlbssl.sh "$OPENLSWS_BSSL"`/$srcdir\/dlbssl.sh "$OPENLSWS_BSSL"/g' configure
sed -i 's/LSRECAPTCHA=`. $srcdir\/src\/modules\/lsrecaptcha\/build_lsrecaptcha.sh`/$srcdir\/src\/modules\/lsrecaptcha\/build_lsrecaptcha.sh/g' configure
autoreconf --force --install
echo Done