memcache-top
============

Real-time monitoring for memcached instances — terminal, JSON, Prometheus, and Grafana.

.. contents:: Table of Contents
   :depth: 2

Features
--------

**Terminal Monitor**
  Live-updating display with color-coded alerts, like ``top`` for memcached.

**Key Inspection**
  Look up any cache key by name (``--get``) or list all stored keys (``--dump``).

**Grafana + Prometheus**
  Built-in Prometheus exporter (``--prometheus``) with a ready-to-import Grafana dashboard.

**JSON Output**
  Machine-readable output (``--json``) for scripts, pipelines, and custom integrations.

**Interactive Controls**
  Toggle columns, change refresh rate, search keys — all without restarting.

**Easy Install**
  Single-file script. Installs as a native Linux command via ``install.sh`` or ``make install``.

Installation
------------

One-line Install
~~~~~~~~~~~~~~~~

.. code-block:: bash

   ./install.sh

That's it. Now ``memcache-top`` works from anywhere on your system.

Other Install Methods
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   # Custom location (no root needed)
   ./install.sh --bindir ~/.local/bin

   # Using make
   make install                       # to /usr/local/bin
   sudo make install                  # if root is needed
   make install PREFIX=/opt           # custom prefix

   # Check dependencies only
   ./install.sh --check

   # Uninstall
   ./install.sh --uninstall
   # or
   make uninstall

Install Inside Docker Containers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add to any Dockerfile:

.. code-block:: dockerfile

   COPY memcache-top /usr/local/bin/memcache-top
   COPY install.sh /tmp/install.sh
   RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm /tmp/install.sh

Or inject into a running container:

.. code-block:: bash

   docker cp memcache-top mycontainer:/usr/local/bin/
   docker cp install.sh mycontainer:/tmp/
   docker exec mycontainer bash -c "chmod +x /tmp/install.sh && /tmp/install.sh"

Quick Start
-----------

.. code-block:: bash

   # Monitor localhost
   memcache-top

   # Monitor specific instances
   memcache-top --instances 10.0.0.1:11211,10.0.0.2:11211

   # Look up a key
   memcache-top --get session:user123

   # JSON output (for scripts)
   memcache-top --json

   # Start Prometheus exporter for Grafana
   memcache-top --prometheus 9150

   # Full Grafana stack with one command
   docker compose up

Grafana Integration
-------------------

memcache-top includes a built-in Prometheus exporter and a pre-configured Grafana dashboard.

Option 1: Full Stack with Docker Compose
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: bash

   docker compose up

This starts:

- **memcached** on port ``11211``
- **memcache-top exporter** on port ``9150`` (Prometheus metrics)
- **Prometheus** on port ``9090`` (scrapes the exporter)
- **Grafana** on port ``3000`` (pre-configured dashboard)

Open **http://localhost:3000** (login: ``admin`` / ``admin``) and the dashboard is already there.

Option 2: Exporter Only (Existing Infrastructure)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you already have Prometheus and Grafana running:

.. code-block:: bash

   # Start the exporter
   memcache-top --instances your-memcached:11211 --prometheus 9150

Add this to your ``prometheus.yml``:

.. code-block:: yaml

   scrape_configs:
     - job_name: 'memcache-top'
       static_configs:
         - targets: ['your-host:9150']

Then import ``grafana/dashboard.json`` into Grafana (Dashboards → Import → Upload JSON).

Dashboard Panels
~~~~~~~~~~~~~~~~

The included Grafana dashboard provides:

========================  ==================================================
Panel                     Description
========================  ==================================================
Instance Status           UP/DOWN status per instance
Memory Usage %            Gauge showing current memory usage
Cache Hit Ratio %         Gauge showing hit ratio (green > 80%, red < 60%)
Current Connections       Connection count per instance
Memory Usage Over Time    Time series of memory usage trends
Cache Hit Ratio Over Time Time series of hit ratio trends
GET/SET Commands          Rate of GET and SET operations per second
Network I/O              Bytes read/written per second
Evictions                 Eviction rate (bar chart, red when > 0)
Current Items             Number of items stored over time
Query Response Time       Stats query latency in milliseconds
Memory: Used vs Allocated Comparison of used vs total memory
Uptime                    Instance uptime
========================  ==================================================

Available Metrics
~~~~~~~~~~~~~~~~~

The ``/metrics`` endpoint exposes these Prometheus metrics:

====================================  ======  ==========================================
Metric                                Type    Description
====================================  ======  ==========================================
``memcached_up``                      gauge   Whether instance is reachable (0/1)
``memcached_usage_percent``           gauge   Memory usage percentage
``memcached_cache_hit_percent``       gauge   Cache hit ratio
``memcached_current_connections``     gauge   Active connections
``memcached_query_time_seconds``      gauge   Time to query stats
``memcached_current_items``           gauge   Items stored in cache
``memcached_evictions_total``         counter Total evictions
``memcached_cmd_get_total``           counter Total GET commands
``memcached_cmd_set_total``           counter Total SET commands
``memcached_get_hits_total``          counter Total GET hits
``memcached_get_misses_total``        counter Total GET misses
``memcached_bytes_read_total``        counter Total bytes read
``memcached_bytes_written_total``     counter Total bytes written
``memcached_bytes``                   gauge   Current bytes used
``memcached_limit_maxbytes``          gauge   Maximum bytes allowed
``memcached_uptime_seconds``          gauge   Instance uptime
====================================  ======  ==========================================

All metrics include the label ``instance="host:port"``.

JSON Output
-----------

For scripting and custom integrations:

.. code-block:: bash

   memcache-top --json

Output:

.. code-block:: json

   {
     "timestamp": 1711036800,
     "instances": [
       {
         "instance": "127.0.0.1:11211",
         "usage": 45.20,
         "cache_hit": 98.50,
         "curr_connections": 12,
         "time_ms": 0.85,
         "curr_items": 15234,
         "evictions": 0.0,
         "cmd_get": 0.0,
         "cmd_set": 0.0,
         "bytes_read": 0.0,
         "bytes_written": 0.0,
         "bytes": 30146560,
         "limit_maxbytes": 67108864
       }
     ],
     "average": { "usage": 45.20, ... },
     "total": { "bytes": 30146560, ... }
   }

Pipe to ``jq`` for quick queries:

.. code-block:: bash

   # Get usage percentage
   memcache-top --json | jq '.instances[0].usage'

   # Alert if hit ratio drops
   memcache-top --json | jq '.instances[] | select(.cache_hit < 60)'

Usage Reference
---------------

.. code-block:: text

   memcache-top [OPTIONS]

All Options
~~~~~~~~~~~

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
``--prometheus <port>``         Start Prometheus exporter on given port
``--json``                      Output stats as JSON (single run)
``--oneoff``                    Run once, no screen clearing (for scripts)
==============================  ================================================

Sort keys: ``usage``, ``hit``, ``conn``, ``time``, ``items``, ``evict``, ``gets``, ``sets``, ``read``, ``write``

Interactive Keys
~~~~~~~~~~~~~~~~

During monitoring, press:

=======  =========================================
Key      Action
=======  =========================================
``q``    Quit
``c``    Toggle color on/off
``b``    Toggle bytes (READ/WRITE) columns
``g``    Toggle get/set commands (GETS/SETS) columns
``l``    Toggle lifetime stats mode
``+``    Increase refresh interval (+1 second)
``-``    Decrease refresh interval (-1 second)
``/``    Search: look up a cache key by name
``d``    Dump: list all cached keys
``h``    Show interactive help screen
=======  =========================================

Column Descriptions
~~~~~~~~~~~~~~~~~~~

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

Examples
--------

.. code-block:: bash

   # Basic monitoring
   memcache-top

   # Multiple instances, sorted by usage
   memcache-top --instances 10.0.0.1:11211,10.0.0.2:11211 --sort usage

   # Fast refresh with all columns
   memcache-top --sleep 1 --commands --bytes

   # Look up a specific key
   memcache-top --get session:user123

   # List all cached keys
   memcache-top --dump

   # JSON for scripting
   memcache-top --json
   memcache-top --json | jq '.instances[] | select(.cache_hit < 80)'

   # Prometheus exporter for Grafana
   memcache-top --instances prod-mc1:11211,prod-mc2:11211 --prometheus 9150

   # Log stats to file
   memcache-top --lifetime --nocolor --oneoff >> stats.log

   # Full Grafana stack
   docker compose up

   # Docker: monitor remote memcached
   docker run -it --network host memcache-top --instances 192.168.1.100:11211

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

Architecture
------------

.. code-block:: text

   ┌──────────────┐     ┌────────────────────┐     ┌────────────┐
   │  memcached   │────▶│  memcache-top       │────▶│  Terminal   │
   │  instances   │     │  --prometheus 9150  │     │  (monitor)  │
   └──────────────┘     └─────────┬──────────┘     └────────────┘
                                  │
                                  │ /metrics
                                  ▼
                          ┌──────────────┐     ┌────────────┐
                          │  Prometheus  │────▶│   Grafana   │
                          │  :9090       │     │   :3000     │
                          └──────────────┘     └────────────┘

Requirements
------------

- Perl 5.x
- ``IO::Socket`` (core module)
- ``Time::HiRes`` (core module)
- Optional: ``Getopt::Long`` (CLI options), ``Term::ANSIColor`` (colors), ``Term::ReadKey`` (interactive keys)

For Docker/Grafana: Docker and Docker Compose.

The installer automatically checks and installs optional dependencies.

License
-------

Open source. See the repository for license details.
