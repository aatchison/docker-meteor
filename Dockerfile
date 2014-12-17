FROM tozd/runit

EXPOSE 3000/tcp

COPY ./etc /etc

ONBUILD COPY . /source
ONBUILD ENV HOME /
ONBUILD RUN apt-get update -q -q && \
 apt-get --yes --force-yes install curl && \
 if [ -x /source/docker-source.sh ]; then /source/docker-source.sh; fi && \
 cp -a /source /build && \
 rm -rf /source && \
 curl https://install.meteor.com/ | sh && \
 cd /build && \
 meteor build . && \
 cd / && \
 tar xf /build/build.tar.gz && \
 rm -rf /build && \
 export NODE=$(find /.meteor/ -path '*bin/node') && \
 ln -sf ${NODE} /usr/local/bin/node && \
 echo "export NODE_PATH=\"$(dirname $(dirname "$NODE"))/lib/node_modules\"" >> /etc/service/meteor/run.env && \
 apt-get --yes --force-yes purge curl && \
 apt-get --yes --force-yes autoremove && \
 adduser --system --group meteor --home /

ENV ROOT_URL http://example.com
ENV MAIL_URL smtp://user:password@mailhost:port/
ENV METEOR_SETTINGS {}
ENV PORT 3000
ENV MONGO_URL mongodb://mongodb/meteor
ENV MONGO_OPLOG_URL mongodb://mongodb/local
