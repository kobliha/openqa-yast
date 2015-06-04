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

# Link all "our_needles" one by one to `opensuse` needles
# That are linked to our distri
cd our_needles
CURRENT_DIR=`pwd`

for NEEDLE in `ls`; do
  LINK="../needles/"${NEEDLE}

  if [ -f "${LINK=}" ]; then
    echo "Link ${LINK} already exists"
  else
    echo "Linking ${NEEDLE}"
    ln -s ${CURRENT_DIR}"/"${NEEDLE} ${LINK}
  fi
done

cd -
