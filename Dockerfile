ARG DEBIAN_DIST=bookworm
FROM debian:$DEBIAN_DIST

ARG DEBIAN_DIST
ARG fresh_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG FRESH_RELEASE

# Upstream's own .deb is the payload: /usr/bin/fresh, the man page, the
# desktop entry, the hicolor icons, the lintian override and the APT install
# receipt (/usr/share/fresh-editor/install-receipt.toml, channel "apt",
# self_update = false) that makes `fresh --cmd update` defer to apt instead of
# overwriting a dpkg-owned binary. Only the control data and the docs are ours.
COPY ${FRESH_RELEASE}/upstream.deb /upstream.deb
RUN dpkg-deb -x /upstream.deb /output && rm /upstream.deb
RUN test -x /output/usr/bin/fresh && test -f /output/usr/share/fresh-editor/install-receipt.toml
RUN rm -f /output/usr/share/doc/fresh-editor/changelog.Debian.gz \
      /output/usr/share/doc/fresh-editor/README.md.gz \
      /output/usr/share/doc/fresh-editor/copyright
RUN mkdir -p /output/DEBIAN

COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/postinst
COPY output/copyright /output/usr/share/doc/fresh-editor/
COPY output/changelog.Debian /output/usr/share/doc/fresh-editor/
COPY output/README.md /output/usr/share/doc/fresh-editor/
RUN chmod 644 /output/usr/share/doc/fresh-editor/*

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/fresh-editor/changelog.Debian
RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/fresh-editor/changelog.Debian
RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
RUN sed -i "s/fresh_VERSION/$fresh_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

RUN cd /output && find usr -type f -print0 | sort -z | xargs -0 md5sum > DEBIAN/md5sums
RUN dpkg-deb --build /output /fresh-editor_${FULL_VERSION}.deb
