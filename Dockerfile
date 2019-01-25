FROM alpine
#MAINTAINER David Personette <dperson@gmail.com>

#Install apt-get
RUN apk update and apk add 
# Install openvpn
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash curl ip6tables iptables openvpn \
                shadow tini && \
    addgroup -S vpn && \
    rm -rf /tmp/*
#Install python3.6
RUN apk add --no-cache python3 && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache
#Selenium / headless firefox
RUN apk --no-cache --no-progress add unzip dbus-x11 ttf-freefont firefox-esr xvfb 

#Moving geckodriver
COPY /vpn/geckodriver /usr/local/bin/
RUN chmod a+x /usr/local/bin/geckodriver

RUN COPY openvpn.sh /usr/bin/

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

VOLUME ["/vpn"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/openvpn.sh"]