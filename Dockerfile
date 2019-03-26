# jnaapti-nginx-proxy
# Build using: sudo docker build -t "jnaapti-nginx-proxy:0.0.1" --rm=true --no-cache .
# Run as: docker run --name "jnaapti-nginx-proxy" -e DEFAULT_HOST=mydev.jnaapti.com -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jnaapti-nginx-proxy:0.0.1
#
# NAME             jnaapti-nginx-proxy
# VERSION          0.0.1
# LAST_UPDATED     2019-03-26

FROM nginx:1.14.1
LABEL maintainer="gautham@jnaapti.com"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/^http {/&\n    server_names_hash_bucket_size 128;/g' /etc/nginx/nginx.conf

# Install Forego
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.4

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
