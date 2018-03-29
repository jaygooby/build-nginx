# About build-nginx
An nginx build tool to simplify downloading and building specific versions of [nginx](http://nginx.org/) with different core and 3rd-party modules.

[![Build Status](https://travis-ci.org/jaygooby/build-nginx.svg?branch=master)](https://travis-ci.org/jaygooby/build-nginx)

[ngx_http_hello_world_module](https://github.com/jaygooby/build-nginx/tree/hello-world-module) courtesy of [perusio](https://github.com/perusio/nginx-hello-world-module) and [kolesar-andras](https://github.com/kolesar-andras/nginx-hello-world-module/tree/content-length)

# TODO                                                                                                                                    

  - [x] Work with git urls                                                                                                                
  - [x] Work with archive urls (gzip & zipped tar releases) (WIP: see [work-with-archive-urls branch](https://github.com/jaygooby/build-nginx/tree/feature/work-with-archive-urls))
  - [ ] Provide different example configurations
  - [ ] Update README with notes about:
    - [ ] 64 bit MacOS Openssl builds
    - [ ] Use non-static Openssl on Mac
    - [ ] How certain modules might implicitly enable the `--with-http_ssl_module` option

# Usage
Basic usage:

```
./build-nginx
```

Will `git --single-branch clone` the nginx `master` branch, configure and build it. Not so very useful...

## Specific nginx version and OpenSSL dependency, with non-core module
How about getting nginx stable version 1.12.2 built with OpenSSL version 1.0.2l and HTTP/2 support?

```
./build-nginx \
-n https://github.com/nginx/nginx.git@release-1.12.2 \
-d https://github.com/openssl/openssl.git@OpenSSL_1_0_2l \
-o --with-http_v2_module
```

Because you've specified OpenSSL as a dependency (`-d`) the nginx configure script automatically gets set with the `--with-openssl=` path.

## Archive URLs as well as git repos
If you don't want to use a git repo, you can also use a source archive:

```
./build-nginx -n http://nginx.org/download/nginx-1.13.6.tar.gz \
              -d https://ftp.pcre.org/pub/pcre/pcre-8.41.tar.gz \
              -d https://www.openssl.org/source/openssl-1.0.2l.tar.gz
```

## 3rd party modules
You can also specify 3rd party modules using the same `git repo url @ version/tag/branch` string or archive url format. In the following example we haven't specifed an nginx version, so we clone from master, but we do clone a forked version of the nginx-upstream-fair module at version 0.1.3

```
./build-nginx \
-m https://github.com/itoffshore/nginx-upstream-fair@0.1.3
```

Because we've specified the module (`-m`) the nginx configure script is automatically called with the `--add-module=` option, pointing to where the module was cloned.

You could also use the official release archive URL:

```
./build-nginx \
-m https://github.com/itoffshore/nginx-upstream-fair/archive/0.1.3.zip
```

## 3rd party modules with a different config folder
Some nginx modules don't have the `config` file in their root, and in these cases you need to let the nginx configure script know where to find it. Do this with an optional folder name after the version; in the example below we're using the nginx NAXI project repository, specifying version `0.55.3` and letting the configure script know it needs to look in the NAXI `naxi_src` folder for the `config` file.

```
./build-nginx \
-n https://github.com/nginx/nginx.git@release-1.12.2 \
-m https://github.com/nbs-system/naxsi.git@0.55.3,naxsi_src
```

## Configuration files
As well as specifying the options to build-nginx on the command line, you can save them into a configuration file, and pass this to the script instead:

```
./build-nginx -k my-special-nginx-config
```

The config file is just a set of command-line options separated by newlines. Comments are permitted. Your `my-special-nginx-config` file might look like:

```
# nginx version 1.0
-n https://github.com/nginx/nginx.git@release-1.0.0
# it all lives in /opt/nginx
-o --prefix=/opt/nginx
-o --with-http_ssl_module # HTTPS
-o --with-debug # helps us debug location directive errors
# Use the OpenSSL in /opt
-o --with-cc-opt=-I/opt/openssl/include
-o --with-ld-opt=-L/opt/openssl/lib
```

## Other options
Call with `-h` to see the full set of options you can use. Currently these are:

```
-b If you want to build from an existing source repo

-c If you only want to clone (download) and not build

-d <dependencies> Specify a git url and branch/tag/version for e.g. pcre

-k <file>  Specify which config file to read this script's arguments from.
           The config file is a text file in which command line arguments
           can be written which then will be used as if they were written on
           the actual command line.

-m <additional modules> Specify a git url, branch/tag/version and
                        optional src folder where nginx looks for the
                        module config file.

-o <options> To pass additional options to the nginx configure script

-s <build directory> The directory where this script will git clone
                     nginx and any modules and dependencies it needs
                     to build. Defaults to ~/src/nginx-build

-n <git-repo and/or version> Optional nginx git repo url and/or optional
                             branch/tag/version. Defaults to
                             https://github.com/nginx/nginx and master.
                             To specify just a branch/tag/version use @branch.
                             To specify both, use git-url@branch
```
