FROM        golang:1.15.7-buster
WORKDIR     /go/src/github.com/adnanh/webhook
ENV         WEBHOOK_VERSION 2.8.0
ENV         APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN         wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb && \
            dpkg -i packages-microsoft-prod.deb && \
            apt-get update && \
            apt-get install -y powershell && \
            rm -rf /var/lib/apt/lists/*
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
            tar -xzf webhook.tar.gz --strip 1 &&  \
            go get -d && \
            go build -o /usr/local/bin/webhook && \
            rm -rf /go
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
