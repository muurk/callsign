========
Callsign
========

:Date: 2013-09-11
:Author: Doug Winter <doug.winter@isotoma.com>
:Website: http://github.com/yaybu/callsign

Description
===========

Callsign is a DNS server for developers. It is intended to serve DNS only for a
single machine - your desktop. It will support automated deployment systems
that coordinate with DNS services, for example Yaybu.

Desktops vary in their client DNS configuration quite widely, and Callsign
supports a number of different modes to enable it to service your DNS effectively.

The DNS service provides recursive queries, so you can continue to use DNS as usual.

You can then set new authoritative domains and A records that are available
locally.

For example::

    $ callsign start
    $ host www.example.com
    www.example.com has address 93.184.216.119
    www.example.com has IPv6 address 2606:2800:220:6d:26bf:1447:1097:aa7
    $ callsign add example.com
    $ callsign record example.com a www 192.168.0.10
    $ callsign show example.com
    www 192.168.0.10
    $ host www.example.com
    www.example.com has address 192.168.0.10
    $ callsign stop
    $ host www.example.com
    www.example.com has address 93.184.216.119
    www.example.com has IPv6 address 2606:2800:220:6d:26bf:1447:1097:aa7

Usage::

    Usage: callsign [options] command

    daemon control commands:
        start  start the callsign server and forward localhost:53 to it
        stop   stop the callsign server and remove iptables rules

    zone commands:
        add name  add a new local authoritative zone "name"
        del name  delete the local authoritative zones "name"
        list      list all authoritative zones
        show name list records for the zone "name"

    record commands:
        record zone a host [data]   create A record
        record zone del host        delete record

        e.g. record example.com a www 192.168.0.1

    Options:
      -h, --help            show this help message and exit
      -c CONFIG, --config=CONFIG
                            path to configuration file

Modes of operation
==================

For the standard libc resolver DNS services must be provided on port 53 - there
is no option for the resolver to consult other ports.

Note that callsign drops privileges once ports are bound, it does not continue to run as root.
configured (which also requires root).

The user that callsign runs as (by default, 'callsign') must already exist on the system. If not installed
by the package manager, run something like:

    sudo useradd -r -s /bin/false callsign

The standard configuration for the libc resolver is in /etc/resolv.conf. This
file will need to have only a single nameserver, 127.0.0.1, configured for
Callsign to work. Callsign provides options to overwrite the configuration in
resolv.conf as part of starting up. It will then replace the previous
configuration when it is stopped.

Finally Callsign requires "forwarders" - other servers that will answer
recursive queries for domains for which Callsign is not authoritative.


Configuring behaviour
---------------------

You can force particular behaviours by setting the "forward" and "rewrite" configuration options:

forward
-------

If this is "true" then the server will not attempt to bind to port 53. If this is "false" then the server will bail if it cannot bind to port 53.

rewrite
-------

If rewrite is false then the server will not attempt to rewrite resolv.conf, but it will still start even if the resolv.conf file does not refer to 127.0.0.1.

Configuration file
==================

A configuration file is not required. Note that Google's DNS servers are used as fallback forwarders by default, as described above.

If you wish, you can provide a file with the following format (defaults are shown)::

    [callsign]
    forwarders = 8.8.8.8 8.8.4.4
    udp_port = 53
    www_port = 5080
    pidfile = /var/run/callsign.pid
    logfile = /var/log/callsign.log
    domains =
    savedir = /var/lib/.callsign
    forward = true
    rewrite = true
    user = callsign

If any domains are listed then only those domains will be allowed::

    domains foo.com bar.com baz.com

Docker
======

Building:

    $ docker build -t callsign:latest .

Executing

    $ docker run -p 127.0.0.1:53:53 -p 127.0.0.1:8053:8053 callsign:latest

API
===

Callsign is designed primarily to be used by automated deployment systems, and
provides a simple REST API for these systems.

In general you should expect the following response codes on a successful request:

 * GET requests return 200 on success
 * PUT requests return 201 on success
 * DELETE requests return 204 on success

The resources available on the web port are:

Root resource: /
----------------

GET
~~~

Return a list of managed zones, one per line, separated by \n.  For example::

    GET /

    200 OK
    example.com
    foo.com

Possible status code responses are:

 * *200* Success

Domain resource: /domain
------------------------

GET
~~~

Return the list of records within this domain, one per line, separated by \n.  For example::

    GET /example.com

    200 OK
    A www 192.168.0.1

Possible status code responses are:

 * *200* Success
 * *404* Domain not found. The domain has not been created as an authoritative zone in callsign.

PUT
~~~

Create this domain.  For example::

    PUT /example.com

    201 Created

Possible status code responses are:

 * *201* Created (success)
 * *200* Domain already exists, unchanged
 * *403* Domain is forbidden (it is not in the list of allowed domains in the configuration file)

DELETE
~~~~~~

Delete this domain.  For example::

    DELETE /example.com

    204 No Content

Possible status code responses are:

 * *204* Success
 * *404* Domain not found. The domain has not been created as an authoritative zone in callsign.

Record resource: /domain/host
-----------------------------

GET
~~~

Return the value for the record.  For example::

    GET /example.com/www

    200 OK
    A 192.168.0.1

Possible status code responses are:

 * *200* Success
 * *404* Record not found

PUT
~~~

Create the record. the payload should be the type and the data, separated by a space.  For example::

    PUT /example.com/www
    A 192.168.0.1

    201 Created

Possible status code responses are:

 * *201* Created (success)
 * *404* Zone not found
 * *400* Malformed request. The reason message will provide more details.

DELETE
~~~~~~

Delete the record. For example::

    DELETE /example.com/www

    204 No Content

Possible status code responses are:

 * *204* Success
 * *404* Domain or record not found

LICENSE
=======

Copyright 2013 Isotoma Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

