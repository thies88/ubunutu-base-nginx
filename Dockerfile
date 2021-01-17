# Runtime stage
# IMPORTANT NOTE: libgl1-mesa-dri and libllvm10 are removed. In next image use: apt --fix-broken install to re-add 
FROM thies88/base-ubuntu

ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Thies88"

RUN \
 echo "### enable src repos ##" && \
 sed -i "/^#.*deb.*main restricted$/s/^# //g" /etc/apt/sources.list && \
 sed -i "/^#.*deb.*universe$/s/^# //g" /etc/apt/sources.list && \

echo "Adding nginx repo to fetch latest version of nginx for ${REL}" && \
echo "deb [arch=${ARCH}] http://nginx.org/packages/mainline/ubuntu/ ${REL} nginx" > /etc/apt/sources.list.d/nginx.list && \
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ ${REL} nginx" >> /etc/apt/sources.list.d/nginx.list && \

curl -o /tmp/nginx_signing.key http://nginx.org/keys/nginx_signing.key && \
apt-key add /tmp/nginx_signing.key && \
rm -rf /tmp/nginx_signing.key && \
 
 # sed -i "/^#.*deb.*multiverse$/s/^# //g" /etc/apt/sources.list && \
 # fix issue when installing certen build-dep sources
 mkdir /usr/share/man/man1/ && \
 echo "**** install packages for building and running/using noVNC ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	nginx && \

echo "**** cleanup ****" && \
apt-get autoremove -y --purge && \
# Clean more temp/junk files
apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/cache/apt/* \
	/var/tmp/* \
	/var/log/* \
	/usr/share/doc/* \
	/usr/share/info/* \
	/var/cache/debconf/* \
	/usr/share/man/* \
	/usr/share/locale/* \
	# clean nginx, we replace tese later on
	/etc/nginx/sites-available/default \
	/etc/nginx/nginx.conf
	
# add local files
COPY root/ /

ENTRYPOINT ["/init"]