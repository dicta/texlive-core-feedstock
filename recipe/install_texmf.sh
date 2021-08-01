#!/bin/bash

set -e
set -x

SHARE_DIR=${PREFIX}/share/texlive

# Copy all the texmf files, ignoring source, documentation, fonts, and scripts.
# NOTE: scripts from this archive are included in texlive-core. What's included
# in the -texmf archive is a superset of what's included in the -source archive,
# and we don't want to install the same files twice.
mkdir -p ${SHARE_DIR}/texmf-dist
shopt -s extglob
cp -r texmf/texmf-dist/!(source|doc|fonts|scripts) ${SHARE_DIR}/texmf-dist

# Config files are customized and installed with texlive-core, don't install
# copies here that would overwrite them
rm ${SHARE_DIR}/texmf-dist/web2c/fmtutil.cnf
rm ${SHARE_DIR}/texmf-dist/web2c/texmf.cnf

# Remove all other files that would otherwise exist in multiple packages.
# NOTE: This list will have to be updated on new editions of TeXLive.
rm ${SHARE_DIR}/texmf-dist/dvipdfmx/dvipdfmx.cfg
rm ${SHARE_DIR}/texmf-dist/dvips/base/color.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/crop.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/finclude.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/hps.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/special.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/texc.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/tex.pro
rm ${SHARE_DIR}/texmf-dist/dvips/base/texps.pro
rm ${SHARE_DIR}/texmf-dist/psutils/paper.cfg
rm ${SHARE_DIR}/texmf-dist/texconfig/tcfmgr
rm ${SHARE_DIR}/texmf-dist/texconfig/tcfmgr.map