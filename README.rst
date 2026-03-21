memcache-top
============

Real-time monitoring for memcached instances, similar to ``top`` for Unix.

Features
--------

- Real-time stats: usage, hit ratio, connections, latency, items, evictions
- Color-coded alerts when metrics exceed configurable thresholds
- Interactive keyboard controls (toggle columns, change refresh rate, etc.)
- Key lookup and dump: search cache by key name, list all keys
- Sort instances by any metric
- Support for multiple memcached instances
- Per-second, lifetime, or cumulative stat modes
- Single-file Perl script, installs as a native Linux command
- Docker support included

Installation
------------

**One-line install (recommended):**

.. code-block:: bash

   # Install as system command (to /usr/local/bin)
   ./install.sh

   # Now use it anywhere:
   memcache-top

**Custom install location (no root needed):**

.. code-block:: bash

   # Install to your home directory
   ./install.sh --bindir ~/.local/bin

   # Or with a custom prefix
   ./install.sh --prefix /opt

**Using make:**

.. code-block:: bash

   make install                    # Install to /usr/local/bin
   sudo make install               # With root if needed
   make install PREFIX=/opt        # Custom prefix
   make uninstall                  # Remove

**Install inside any Docker container:**

.. code-block:: dockerfile

   # Add to your own Dockerfile
   COPY memcache-top /usr/local/bin/memcache-top
   COPY install.sh /tmp/install.sh
   RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

Or in a running container:

.. code-block:: bash

   docker cp memcache-top mycontainer:/usr/local/bin/
   docker cp install.sh mycontainer:/tmp/
   docker exec mycontainer bash -c "chmod +x /tmp/install.sh && /tmp/install.sh"

**Verify / check dependencies:**

.. code-block:: bash

   ./install.sh --check

**Uninstall:**

.. code-block:: bash

   ./install.sh --uninstall
   # or
   make uninstall

**Using the Docker image:**

.. code-block:: bash

   # Build and run with docker-compose (starts memcached + monitor)
   docker compose up

   # Or build and run standalone
   docker build -t memcache-top .
   docker run -it --network host memcache-top --instances 127.0.0.1:11211

Quick Start
-----------

.. code-block:: bash

   # After installation, just run:
   memcache-top

   # Or run directly without installing:
   chmod +x memcache-top
   ./memcache-top

   # Show help:
   memcache-top --help

Usage
-----

.. code-block:: text

   memcache-top [OPTIONS]

Options
~~~~~~~

==============================  ================================================
Option                          Description
==============================  ================================================
``-h, --help``                  Show help message
``--instances <host:port>``     Memcached instances (comma-separated or multiple)
``--port <num>``                Default port (default: 11211)
``--sleep <seconds>``           Refresh interval (default: 3)
``--timeout <seconds>``         Connection timeout (default: 2)
``--color / --nocolor``         Enable/disable colored output
``--lifetime / --nolifetime``   Show lifetime stats vs per-second
``--bytes / --nobytes``         Show read/write bytes (default: on)
``--commands / --nocommands``   Show get/set commands (default: off)
``--cumulative``                Show cumulative stats since start
``--sort <key>``                Sort instances by metric (descending)
``--get <key>``                 Look up a key and display its value
``--dump``                      List all cached keys (then exit)
``--oneoff``                    Run once, no screen clearing (for scripts)
==============================  ================================================

Sort keys: ``usage``, ``hit``, ``conn``, ``time``, ``items``, ``evict``, ``gets``, ``sets``, ``read``, ``write``

Interactive Keys
~~~~~~~~~~~~~~~~

During monitoring, press:

=====  =========================================
Key    Action
=====  =========================================
``q``  Quit
``c``  Toggle color on/off
``b``  Toggle bytes (READ/WRITE) columns
``g``  Toggle get/set commands (GETS/SETS) columns
``l``  Toggle lifetime stats mode
``+``  Increase refresh interval (+1 second)
``-``  Decrease refresh interval (-1 second)
``/``  Search: look up a cache key by name
``d``  Dump: list all cached keys
``h``  Show interactive help screen
=====  =========================================

Examples
--------

.. code-block:: bash

   # Monitor default localhost:11211
   memcache-top

   # Monitor multiple instances, sorted by usage
   memcache-top --instances 10.0.0.1:11211,10.0.0.2:11211 --sort usage

   # Fast refresh with all columns
   memcache-top --sleep 1 --commands --bytes

   # Look up a specific key
   memcache-top --get session:user123

   # List all cached keys
   memcache-top --dump

   # Lifetime stats, no color (for logging)
   memcache-top --lifetime --nocolor --oneoff >> stats.log

   # Docker: monitor a remote memcached
   docker run -it --network host memcache-top --instances 192.168.1.100:11211

Column Descriptions
-------------------

=========  ====================================================
Column     Description
=========  ====================================================
USAGE      Memory usage percentage
HIT %      Cache hit ratio (higher is better)
CONN       Current active connections
TIME       Stats query response time
ITEMS      Current items stored in cache
EVICT/s    Evictions per second (or total in lifetime mode)
GETS/s     GET commands per second
SETS/s     SET commands per second
READ/s     Bytes read per second
WRITE/s    Bytes written per second
=========  ====================================================

Values highlighted in **red** indicate they have exceeded the configured threshold.

Thresholds
----------

Edit the ``%threshold`` hash in the script to customize alert levels:

.. code-block:: perl

   %threshold = (
       cache_hit        => 60,       # Alert if hit ratio below 60%
       usage            => 90,       # Alert if usage above 90%
       time             => 5,        # Alert if query time above 5ms
       evictions        => 0,        # Alert on any evictions
       curr_connections => 3500,     # Alert if connections above 3500
       bytes_read       => 1000000,  # Alert if reads above 1MB/s
       bytes_written    => 1000000,  # Alert if writes above 1MB/s
   );

Requirements
------------

- Perl 5.x
- ``IO::Socket`` (core module)
- ``Time::HiRes`` (core module)
- Optional: ``Getopt::Long`` (for CLI options), ``Term::ANSIColor`` (for colors), ``Term::ReadKey`` (for interactive keys)

The installer automatically checks and installs optional dependencies.

License
-------

Open source. See the repository for license details.
