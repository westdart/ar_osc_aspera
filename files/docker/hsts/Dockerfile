FROM aspera-base

ARG package_url
ARG username

ADD $package_url /tmp/aspera.rpm

RUN rpm -Uvh /tmp/aspera.rpm \
 && usermod -s /bin/aspshell $username \
 && chown -R $username:root /opt/aspera \
 && mkdir /desbs \
 && chown $username:root /desbs \
 && chmod 770 /desbs \
 && echo "HSTS" > /aspera-type

USER 10001
