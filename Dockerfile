FROM debian:bullseye

ARG POSTGRES_VERSION=14
ARG PGBACKREST_VERSION=2.37-1.pgdg110+1

RUN set -ex; \
        groupadd -r pgbackrest --gid=102 && useradd -r -g pgbackrest -d /var/lib/pgbackrest --uid=101 -s /bin/bash pgbackrest

RUN set -ex; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends lsb-release gnupg2 xz-utils ca-certificates curl; \
	curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null; \
	echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
	apt-get update; \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		cron \
		pgbackrest=${PGBACKREST_VERSION} \
		postgresql-client-${POSTGRES_VERSION}; \
	chown pgbackrest:pgbackrest /var/lib/pgbackrest; \
	apt-get purge -y gnupg2 lsb-release; \
	rm -rf /var/lib/apt/lists/*

ENV S6_OVERLAY_VERSION 3.0.0.2-2

RUN set -ex; \
        curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch-${S6_OVERLAY_VERSION}.tar.xz -o /tmp/s6-overlay-noarch.tar.xz ; \
        tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz ;\
        rm /tmp/s6-overlay-noarch.tar.xz ;\
        curl -L https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64-${S6_OVERLAY_VERSION}.tar.xz -o /tmp/s6-overlay-x86_64.tar.xz ; \
        tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz ;\
        rm /tmp/s6-overlay-x86_64.tar.xz

COPY services.d /etc/services.d

VOLUME /var/lib/pgbackrest

ENTRYPOINT ["/init"]
