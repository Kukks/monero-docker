# runtime stage
FROM debian:stretch-slim

ENV FILE=monero-linux-x64-v0.14.1.2.tar.bz2
ENV FILE_CHECKSUM=a4d1ddb9a6f36fcb985a3c07101756f544a5c9f797edd0885dab4a9de27a6228
RUN apt-get update \
    && apt-get -y --no-install-recommends install gzip ca-certificates curl 
	
RUN curl -L -O https://dlsrc.getmonero.org/cli/$FILE 

RUN echo "$FILE_CHECKSUM $FILE" | sha256sum -c - 
RUN mkdir -p extracted 
RUN tar -zxvf $FILE -C /extracted 
RUN find /extracted/ -type f -print0 | xargs -0 mv -t /usr/local/bin/
RUN rm -rf extracted && rm $FILE 
RUN apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

COPY ./scripts /scripts/
# Create monero user
RUN adduser --system --group --disabled-password monero && \
	mkdir -p /wallet /home/monero/.bitmonero && \
	chown -R monero:monero /home/monero/.bitmonero && \
	chown -R monero:monero /wallet

# Contains the blockchain
VOLUME /home/monero/.bitmonero

# Generate your wallet via accessing the container and run:
# cd /wallet
# monero-wallet-cli
VOLUME /wallet

EXPOSE 18080
EXPOSE 18081
EXPOSE 18082
# switch to user monero
USER monero


