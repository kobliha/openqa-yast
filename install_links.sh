#!/bin/bash

# Link lib and needles from `opensuse` distri
# if they already exist, they are removed and recreated again
if [ -L lib ]; then
    rm -rf lib
fi
ln -s ../opensuse/lib lib

if [ -L needles ]; then
    rm -rf needles
fi
ln -s ../opensuse/needles needles

# Link all "our_*/*" one by one to `opensuse` needles
# That are linked to our distri
for DIR in `ls | grep 'our_.*' | sed 's/our_//'`; do
    cd our_${DIR}
    CURRENT_DIR=`pwd`
    echo "Creating links to "${CURRENT_DIR}

    for TARGET in `ls`; do
      LINK="../"${DIR}"/"${TARGET}

      if [ -f "${LINK=}" ]; then
        echo "Link ${LINK} already exists"
      else
        echo "Linking ${TARGET}"
        ln -s ${CURRENT_DIR}"/"${TARGET} ${LINK}
      fi
    done

    cd -
done
