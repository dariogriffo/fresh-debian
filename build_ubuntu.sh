fresh_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$fresh_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <fresh_version> <build_version> [architecture]"
    echo "Example: $0 0.5.2 1 arm64"
    echo "Example: $0 0.5.2 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Upstream tags carry a "v" prefix. Every release attaches a ready-made .deb
# per architecture, named after the Debian architecture spelling and always
# with Debian revision 1 (fresh-editor_<version>-1_<arch>.deb).
UPSTREAM_URL="https://github.com/sinelaw/fresh/releases/download/v${fresh_VERSION}"

# Function to map Debian architecture to the upstream .deb asset name.
# That .deb carries a glibc build that needs only glibc 2.30 and libgcc_s, so
# it runs on every suite we target; its contents (binary, man page, desktop
# entry, icons, APT install receipt) are repackaged as-is.
get_fresh_release() {
    local arch=$1
    case "$arch" in
        "amd64"|"arm64") echo "fresh-editor_${fresh_VERSION}-1_${arch}" ;;
        *)               echo "" ;;
    esac
}

# The upstream .deb is downloaded into a directory of its own so that it can
# never be mistaken for one of the packages this script produces.
download_release() {
    local release=$1

    rm -rf "$release" || true
    mkdir -p "$release"

    if ! wget -q "${UPSTREAM_URL}/${release}.deb" -O "$release/upstream.deb"; then
        echo "❌ Failed to download ${release}.deb"
        return 1
    fi

    if [ "$(head -c 7 "$release/upstream.deb")" != '!<arch>' ]; then
        echo "❌ Unexpected upstream package layout for $release (not a .deb)"
        return 1
    fi
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local fresh_release

    fresh_release=$(get_fresh_release "$build_arch")
    if [ -z "$fresh_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $fresh_release"

    if ! download_release "$fresh_release"; then
        echo "❌ Failed to prepare fresh-editor package for $build_arch"
        return 1
    fi

    # Upstream ships Linux packages for amd64/arm64 only, and both work on
    # every Ubuntu suite we target.
    declare -a arr=("jammy" "noble" "questing" "resolute")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$fresh_VERSION-${BUILD_VERSION}~${dist}_${build_arch}_ubu"
        echo "  Building $FULL_VERSION"

        if ! docker build . -f Dockerfile.ubu -t "fresh-editor-ubuntu-$dist-$build_arch" \
            --build-arg UBUNTU_DIST="$dist" \
            --build-arg fresh_VERSION="$fresh_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg FRESH_RELEASE="$fresh_release"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "fresh-editor-ubuntu-$dist-$build_arch")"
        if ! docker cp "$id:/fresh-editor_$FULL_VERSION.deb" - > "./fresh-editor_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./fresh-editor_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up downloaded directory
    rm -rf "$fresh_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building fresh-editor $fresh_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la fresh-editor_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
