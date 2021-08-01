#! /bin/bash

set -e
set -x

SHARE_DIR=${PREFIX}/share/texlive

# Copy all the fonts out of the texmf distribution.
mkdir -p ${SHARE_DIR}/texmf-dist
cp -r texmf/texmf-dist/fonts ${SHARE_DIR}/texmf-dist
