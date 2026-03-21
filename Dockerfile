FROM perl:5-slim

RUN cpanm --notest Term::ReadKey Term::ANSIColor || true

COPY memcache-top /usr/local/bin/memcache-top
RUN chmod +x /usr/local/bin/memcache-top

ENTRYPOINT ["memcache-top"]
CMD ["--help"]
