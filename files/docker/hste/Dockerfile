FROM aspera-base

ARG package_url
ARG username

ADD $package_url /tmp/aspera.rpm

RUN rpm -Uvh /tmp/aspera.rpm \
 && usermod -s /bin/aspshell $username \
 && chown -R $username:root /opt/aspera \
 && mkdir /mjdi \
 && chown $username:root /mjdi \
 && chmod 770 /mjdi \
 && echo "HSTE" > /aspera-type

USER 10001
