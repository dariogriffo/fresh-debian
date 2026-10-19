#!/bin/bash
set -euo pipefail

fresh_VERSION=$1
BUILD_VERSION=$2

if [ -z "$fresh_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <fresh_version> <build_version>"
    echo "Example: $0 0.5.2 1"
    exit 1
fi

PACKAGE_NAME="fresh-editor"
ORIG_TARBALL="${PACKAGE_NAME}_${fresh_VERSION}.orig.tar.gz"
BUILD_DIR="${PACKAGE_NAME}-${fresh_VERSION}"

echo "Creating the source package for fresh-editor ${fresh_VERSION}-${BUILD_VERSION}..."

# A rebuild of an upstream version already released here (a +N build bump)
# must ship the very same orig tarball: the pool holds one per upstream
# version and reprepro refuses a different one, and nothing guarantees the
# archive download is byte-identical next time. Reuse the earlier release's copy.
if [ ! -f "$ORIG_TARBALL" ]; then
    for ((b = BUILD_VERSION - 1; b >= 1; b--)); do
        if wget -q "https://github.com/dariogriffo/fresh-debian/releases/download/${fresh_VERSION}%2B${b}/${ORIG_TARBALL}" -O "$ORIG_TARBALL"; then
            echo "  Reusing $ORIG_TARBALL from release ${fresh_VERSION}+${b}"
            break
        fi
        rm -f "$ORIG_TARBALL"
    done
fi

# Download upstream source tarball (shared .orig.tar.gz across all distributions).
# Upstream tags carry a "v" prefix, which GitHub strips from the archive's top
# level directory, so the archive extracts as fresh-<version>/. It is used
# byte-for-byte with no repacking; dpkg-source does not care about the name of
# the top level directory inside the .orig tarball.
UPSTREAM_DIR="fresh-${fresh_VERSION}"
if [ ! -f "$ORIG_TARBALL" ]; then
    echo "Downloading upstream source from GitHub..."
    wget -q "https://github.com/sinelaw/fresh/archive/refs/tags/v${fresh_VERSION}.tar.gz" -O "$ORIG_TARBALL"
    echo "  Downloaded $ORIG_TARBALL"
else
    echo "  Using existing $ORIG_TARBALL"
fi

build_source_package() {
    local FULL_VERSION="${fresh_VERSION}-${BUILD_VERSION}~griffo"

    echo "  Building source package ${FULL_VERSION}..."

    # Clean and recreate build directory from orig tarball
    rm -rf "$BUILD_DIR"
    rm -rf "$UPSTREAM_DIR"
    tar -xf "$ORIG_TARBALL"
    # GitHub archives extract as fresh-0.x.y/; the source package is named
    # after the binary package, fresh-editor.
    mv "$UPSTREAM_DIR" "$BUILD_DIR"

    # Upstream's source tree carries its own debian/ (it builds its own .deb
    # from source with cargo). Drop it entirely so none of its .install,
    # .manpages or source/options files leak into our packaging.
    rm -rf "$BUILD_DIR/debian"

    # Copy Debian packaging directory
    cp -r debian "$BUILD_DIR/"

    # Generate the changelog (overwrites placeholder)
    cat > "$BUILD_DIR/debian/changelog" << EOC
fresh-editor (${FULL_VERSION}) stable; urgency=medium

  * New upstream release ${fresh_VERSION}.

 -- Dario Griffo <dariogriffo@gmail.com>  $(date -R)
EOC

    # Build source package (.dsc + .debian.tar.xz); reuses existing .orig.tar.gz
    dpkg-source -b "$BUILD_DIR"

    rm -rf "$BUILD_DIR"
    echo "    ${FULL_VERSION}"
}

echo ""
# One source package for every suite, as with the binaries (see build_debian.sh).
build_source_package

echo ""
echo "Source packages created successfully!"
echo ""
echo "Generated files:"
ls -la "${PACKAGE_NAME}_"*.dsc "${PACKAGE_NAME}_"*.orig.tar.gz "${PACKAGE_NAME}_"*.debian.tar.xz 2>/dev/null || true
