FROM ghcr.io/void-linux/void-linux:latest-full-x86_64-musl as python3
RUN xbps-install -Sy \
        bash \
        base-devel \
        libffi-devel \
        libgdal \
        libjpeg-turbo-devel \
        libspatialite \
        nginx \
        openssl-devel \
        python3 \
        python3-devel \
        python3-pip \
        redis \
        tini \
        vsv \
        zlib-devel

RUN useradd \
        --comment "OpenWISP Unprivileged User" \
        --skel /var/empty \
        --create-home \
        --home-dir /opt/openwisp \
        --system \
        --user-group \
        --groups nginx \
        _openwisp

RUN pip install supervisor && \
        mkdir -vp /etc/sv/supervisord /etc/supervisord.conf.d && \
        echo '#!/bin/sh\nexec chpst -u _openwisp supervisord -c /etc/supervisord.conf\n' > /etc/sv/supervisord/run && \
        chmod +x /etc/sv/supervisord/run && \
        mkdir -vp /persist /run/runit /run/openwisp /service /var/log/openwisp && \
        chown -R _openwisp:_openwisp /run/openwisp /var/log/openwisp /persist && \
        ln -sf /service /var/service && \
        ln -sf /etc/sv/redis /service && \
        ln -sf /etc/sv/nginx /service && \
        ln -sf /etc/sv/supervisord /service

FROM python3 as openwisp-pkgs
USER _openwisp
WORKDIR /opt/openwisp
COPY requirements.txt .
RUN     python3 -m venv venv && . venv/bin/activate && \
        pip install setuptools wheel attrs && \
        pip install -r requirements.txt && \
        mkdir log

FROM openwisp-pkgs as openwisp
VOLUME /persist
COPY conf/uwsgi.ini .
COPY openwisp/*.py ./openwisp2/
COPY manage.py manage.py
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf
COPY supervisor/ /etc/supervisord.conf.d/
RUN . venv/bin/activate && python manage.py collectstatic && \
        chown -R _openwisp:nginx static && chmod -R g+rX static && \
        chmod 0755 .
USER root
ENTRYPOINT ["/usr/bin/tini", "/usr/bin/runsvdir", "/var/service"]
