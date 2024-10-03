# First stage: Base NGINX setup
FROM alpine:3.20 AS base

LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"

ENV NGINX_VERSION=1.26.2
ENV PKG_RELEASE=1
ENV DYNPKG_RELEASE=2

RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache --virtual .checksum-deps \
        openssl \
    && apkArch="$(cat /etc/apk/arch)" \
    && nginxPackages="nginx=${NGINX_VERSION}-r${PKG_RELEASE}" \
    && case "$apkArch" in \
        x86_64|aarch64) \
            wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && echo "e09fa32f0a0eab2b879ccbbc4d0e4fb9751486eedda75e35fac65802cc9faa266425edf83e261137a2f4d16281ce2c1a5f4502930fe75154723da014214f0655 */tmp/nginx_signing.rsa.pub" | sha512sum -c - \
            && mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/ \
            && apk add -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
            ;; \
        *) \
            apk add --no-cache --virtual .build-deps gcc libc-dev make openssl-dev pcre2-dev zlib-dev linux-headers bash alpine-sdk \
            && tempDir="$(mktemp -d)" \
            && su nobody -s /bin/sh -c " \
                cd ${tempDir} \
                && curl -f -L -O https://github.com/nginx/pkg-oss/archive/${NGINX_VERSION}-${PKG_RELEASE}.tar.gz \
                && tar xzvf ${NGINX_VERSION}-${PKG_RELEASE}.tar.gz \
                && cd pkg-oss-${NGINX_VERSION}-${PKG_RELEASE}/alpine \
                && make base \
                && apk index --allow-untrusted -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk" \
            && apk del --no-network .build-deps \
            && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
            ;; \
    esac \
    && apk del --no-network .checksum-deps \
    && apk add --no-cache tzdata gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$( \
        scanelf --needed --nobanner /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
    )" \
    && apk add --no-cache $runDeps \
    && apk del --no-network gettext \
    && mv /tmp/envsubst /usr/local/bin/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir /docker-entrypoint.d

COPY docker-entrypoint.sh /
COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY 15-local-resolvers.envsh /docker-entrypoint.d
COPY 20-envsubst-on-templates.sh /docker-entrypoint.d
COPY 30-tune-worker-processes.sh /docker-entrypoint.d
EXPOSE 80

STOPSIGNAL SIGQUIT
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

# Second stage: Module building
FROM base AS builder

ARG ENABLED_MODULES
RUN apk update \
    && apk add linux-headers openssl-dev pcre2-dev zlib-dev openssl abuild \
               musl-dev libxslt libxml2-utils make mercurial gcc unzip git \
               xz g++ coreutils curl \
    # allow abuild as a root user \
    && printf "#!/bin/sh\\nSETFATTR=true /usr/bin/abuild -F \"\$@\"\\n" > /usr/local/bin/abuild \
    && chmod +x /usr/local/bin/abuild \
    && git clone -b ${NGINX_VERSION}-${PKG_RELEASE} https://github.com/nginx/pkg-oss/ \
    && cd pkg-oss \
    && mkdir /tmp/packages \
    && for module in $ENABLED_MODULES; do \
        echo "Building $module for nginx-$NGINX_VERSION"; \
        if [ -d /modules/$module ]; then \
            echo "Building $module from user-supplied sources"; \
            # check if module sources file is there and not empty
            if [ ! -s /modules/$module/source ]; then \
                echo "No source file for $module in modules/$module/source, exiting"; \
                exit 1; \
            fi; \
            # some modules require build dependencies
            if [ -f /modules/$module/build-deps ]; then \
                echo "Installing $module build dependencies"; \
                apk update && apk add $(cat /modules/$module/build-deps | xargs); \
            fi; \
            # if a module has a build dependency that is not in a distro, provide a
            # shell script to fetch/build/install those
            # note that shared libraries produced as a result of this script will
            # not be copied from the builder image to the main one so build static
            if [ -x /modules/$module/prebuild ]; then \
                echo "Running prebuild script for $module"; \
                /modules/$module/prebuild; \
            fi; \
            /pkg-oss/build_module.sh -v $NGINX_VERSION -f -y -o /tmp/packages -n $module $(cat /modules/$module/source); \
            BUILT_MODULES="$BUILT_MODULES $(echo $module | tr '[A-Z]' '[a-z]' | tr -d '[/_\-\.\t ]')"; \
        elif make -C /pkg-oss/alpine list | grep -E "^$module\s+\d+" > /dev/null; then \
            echo "Building $module from pkg-oss sources"; \
            cd /pkg-oss/alpine; \
            make abuild-module-$module BASE_VERSION=$NGINX_VERSION NGINX_VERSION=$NGINX_VERSION; \
            apk add $(. ./abuild-module-$module/APKBUILD; echo $makedepends;); \
            make module-$module BASE_VERSION=$NGINX_VERSION NGINX_VERSION=$NGINX_VERSION; \
            find ~/packages -type f -name "*.apk" -exec mv -v {} /tmp/packages/ \;; \
            BUILT_MODULES="$BUILT_MODULES $module"; \
        else \
            echo "Don't know how to build $module module, exiting"; \
            exit 1; \
        fi; \
    done \
    && echo "BUILT_MODULES=\"$BUILT_MODULES\"" > /tmp/packages/modules.env

# Final stage: Assemble NGINX with modules
FROM base

# Ensure the /tmp/packages folder exists in the builder stage
COPY --from=builder /tmp/packages /tmp/packages

# Debugging to see if packages are there
RUN ls -l /tmp/packages

RUN apk add --no-cache --allow-untrusted /tmp/packages/*.apk

CMD ["nginx", "-g", "daemon off;"]
