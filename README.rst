memcache-top.pl
===============

"top" for memcache - watch the traffic and other stats in real-time.  Yoikes.

NOTES
-----

   - Specify instances w/ --instances (multiple times or comma separated)
   - Specify default port w/ --port (defaults to 11211)
   - Specify sleep time w/ --sleep (default 3), or as a bare number
   - Specify color output w/ --color (default) or --nocolor
   - Specify lifetime stats (averaged over server uptime) w/ --lifetime
   - Specify read and write bytes columns w/ --bytes or --nobytes (default)
   - Specify get and set columns w/ --commands (default) or --nocommands
   - Specify cumulative numbers (since start of run) w/ --cumulative
   - Run a single time without clearing the screen, good for scripts and
     monitoring checks: --oneoff.  Exit code is 0 OK, 1 WARNING, 2 CRITICAL.

   Thresholds live in %limit at the top of the script.  Each metric has a
   warning (yellow) and a critical (red) level; the ALERTS panel explains
   what is wrong.  It flags: instance down, recent restart (cold cache),
   slow 'stats' round-trip, connections near max_connections, rejected
   connections, evictions and a low hit ratio under real traffic.
   Written against memcached v 1.2.3, but works fine w/ later versions.
