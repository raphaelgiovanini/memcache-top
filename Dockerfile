FROM perl:5-slim

RUN cpanm --notest Term::ReadKey Term::ANSIColor || true

COPY memcache-top /usr/local/bin/memcache-top
COPY install.sh /usr/local/share/memcache-top/install.sh
RUN chmod +x /usr/local/bin/memcache-top /usr/local/share/memcache-top/install.sh

ENTRYPOINT ["memcache-top"]
CMD ["--help"]
