[![Build Status](https://secure.travis-ci.org/openSUSE/open-build-service.svg?branch=master)](https://travis-ci.org/openSUSE/open-build-service)
[![Code Climate](https://codeclimate.com/github/openSUSE/open-build-service.png)](https://codeclimate.com/github/openSUSE/open-build-service)
[![Coverage Status](https://img.shields.io/coveralls/openSUSE/open-build-service.svg)](https://coveralls.io/r/openSUSE/open-build-service)

# Open Build Service
The [Open Build Service (OBS)](http://www.open-build-service.org) is a generic system to build and distribute binary packages from sources in an automatic, consistent and reproducible way. You can release packages as well as updates, add-ons, appliances and entire distributions for a wide range of operating systems and hardware architectures. More information can be found on [openbuildservice.org](http://www.openbuildservice.org).

The OBS consists of a backend and a frontend. The backend implements all the core functionality (i.e. building packages). The frontend provides a web application and XML API for interacting with the backend. Additionally there is a command line client (osc) for the API which is developed in a [separate repository](https://github.com/openSUSE/osc).

## Licensing
The Open Build Service is Free Software and is released under the terms of the GPL, except where noted. Additionally, 3rd-party content (like, but not exclusively, the webui icon theme) may be released under a different license. Please check the respective files for details.

## Community
You can discuss with the OBS Team via IRC on the channel [#opensuse-buildservice](irc://freenode.net/opensuse-buildservice). Or you can use our mailing list [opensuse-buildservice@opensuse.org](mailto:opensuse-buildservice+subscribe@opensuse.org).

### Development / Contribution
If you want to contribute to the OBS please checkout our [contribution readme](CONTRIBUTING.md):-)

## Source Code Repository Layout
The OBS source code repository is hosted on [Github](http://github.com/opensuse/open-build-service) and organized like this:

        dist          Files relevant for our distribution packages
        docs          Documentation, examples and schema files
        src/api       Rails app (Ruby on Rails)
        src/backend   Backend code (Perl)

## Setup
There are 3 scenarios for which you can setup an OBS instance.

1. Use the OBS appliance

  To run the OBS in production we recommend using our [OBS appliance](http://openbuildservice.org/download/) which is the whole package:
  a recent and stable Linux Operating System ([openSUSE](http://www.opensuse.org)) bundled and pre-configured with all the server and
  OBS components you need to get going.

2. Install packages and run the setup wizard

  This installation method is recommended if you have some special needs for your setup (e.g. different partition schema, SLES as base system, etc.).

  After finishing the installation of your base system, follow the following steps:

  1. Add the OBS software repository with zypper

    Please be aware, that the needed URL might differ, depending on your Operating System.
    (We use openSUSE Leap 42.1 in this example)

        zypper ar -f http://download.opensuse.org/repositories/OBS:/Server:/2.7/openSUSE_42.1/OBS:Server:2.7.repo

        zypper in obs-api obs-server

  2. Run our setup wizard

        ```
        /usr/lib/obs/server/setup-appliance.sh
        ```


3. Install packages and configure your system manually

    If you have a more complex setup (e.g. a distributed backend) we recommend to follow our [Manual Setup Guide](dist/README.SETUP.md)

## Advanced Setup

Please see the administration chapter in our [reference manual](http://openbuildservice.org/help/manuals/obs-reference-guide/cha.obs.admin.html) for details on complex setups.

