#! /bin/bash


set -e
set -x

TEST_SEGFAULT=no

unset TEXMFCNF; export TEXMFCNF
LANG=C; export LANG

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

# Need the fallback path for testing in some cases.
if [ "$(uname)" == "Darwin" ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

SHARE_DIR=${PREFIX}/share/texlive

[[ -d "${SHARE_DIR}/texmf-dist/scripts/texlive" ]] || mkdir -p "${SHARE_DIR}/texmf-dist/scripts/texlive"

# Copy perl module from the extras tarball. This specific directory is selected
# so that it is in the Perl search path of texlive tools
[[ -d "${SHARE_DIR}/tlpkg" ]] || mkdir -p "${SHARE_DIR}/tlpkg"
cp -vr extra/tlpkg/TeXLive ${SHARE_DIR}/tlpkg/TeXLive

pushd forgebuild
  # make check reads files from the installation prefix:
  make install -j${CPU_COUNT}
  if [[ ! ${target_platform} =~ .*linux.* ]]; then
    VERBOSE=1 LC_ALL=C make check ${VERBOSE_AT}
  elif [[ ${TEST_SEGFAULT} == yes ]] && [[ ${target_platform} =~ .*linux.* ]]; then
    LC_ALL=C make check ${VERBOSE_AT}
    echo "pushd ${SRC_DIR}/forgebuild/texk/web2c"
    echo "LC_ALL=C make check ${VERBOSE_AT}"
    echo "cat mplibdir/mptraptest.log"
    pushd "${SRC_DIR}/forgebuild/texk/web2c/mpost"
      # I believe mpost test fails here because it tries to load mpost itself as a configuration file
      # .. this happens in both failing tests on Linux. Debug builds (CFLAGS-wise) do not suffer a
      # segfault at this point but release ones. Skipping for now, will re-visit later.
      LC_ALL=C ../mpost --ini ../mpost
    popd
    exit 1
  fi
popd

# Remove info and man pages.
rm -rf ${SHARE_DIR}/man
rm -rf ${SHARE_DIR}/info

# Populate complete set of scripts from texmf tarball
rm -rf ${SHARE_DIR}/texmf-dist/scripts
cp -r  texmf/texmf-dist/scripts ${SHARE_DIR}/texmf-dist/scripts

# Patch tlmgr script to use the correct variable when searching for perl modules
sed \
    -e 's|Master = `kpsewhich -var-value=SELFAUTOPARENT`|Master = `kpsewhich -var-value=TEXMFROOT`|' \
    <texmf/texmf-dist/scripts/texlive/tlmgr.pl > ${SHARE_DIR}/texmf-dist/scripts/texlive/tlmgr.pl

mv ${SHARE_DIR}/texmf-dist/web2c/texmf.cnf tmp.cnf
sed \
    -e "s|TEXMFROOT =.*|TEXMFROOT = \$SELFAUTODIR/share/texlive|" \
    -e "s|TEXMFLOCAL =.*|TEXMFLOCAL = \$TEXMFROOT/texmf-local|" \
    <tmp.cnf >${SHARE_DIR}/texmf-dist/web2c/texmf.cnf
rm -f tmp.cnf

# Create symlinks for pdflatex and latex
ln -s $PREFIX/bin/pdftex $PREFIX/bin/pdflatex
ln -s $PREFIX/bin/pdftex $PREFIX/bin/latex
