FROM debian:bullseye

LABEL maintainer="codestation <codestation@megpoid.dev>"

ARG POSTGRES_VERSION=14
ARG BACKREST_VERSION=2.40-2.pgdg110+1
ARG S6_OVERLAY_VERSION=3.1.0.1

RUN set -ex; \
	groupadd -r pgbackrest --gid=999; \
	useradd -r -g pgbackrest -d /var/lib/pgbackrest --uid=999 -s /bin/bash pgbackrest

RUN set -ex; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends lsb-release gnupg2 xz-utils ca-certificates curl; \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null; \
	echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		cron \
		pgbackrest=${BACKREST_VERSION} \
		postgresql-client-${POSTGRES_VERSION} \
	; \
	apt-get purge -y gnupg2 lsb-release; \
	chown pgbackrest:pgbackrest /var/log/pgbackrest; \
	chown pgbackrest:pgbackrest /var/lib/pgbackrest; \
	rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz ; \
	tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz ;\
	rm /tmp/s6-overlay-noarch.tar.xz ;\
	curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-$(arch).tar.xz -o /tmp/s6-overlay-$(arch).tar.xz ; \
	tar -C / -Jxpf /tmp/s6-overlay-$(arch).tar.xz ;\
	rm /tmp/s6-overlay-$(arch).tar.xz

COPY services/ /etc/s6-overlay/s6-rc.d/

VOLUME /var/lib/pgbackrest

ENTRYPOINT ["/init"]
