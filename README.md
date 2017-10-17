# About build-nginx
An nginx build tool to simplify downloading and building specific versions of [nginx](http://nginx.org/) with different core and 3rd-party modules.

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

## 3rd party modules
You can also specify 3rd party modules using the same `git repo url @ version/tag/branch` string. In the following example we haven't specifed an nginx version, so we clone from master, but we do clone a forked version of the nginx-upstream-fair module at version 0.1.3

```
./build-nginx \
-m https://github.com/itoffshore/nginx-upstream-fair@0.1.3
```

Because we've specified the module (`-m`) the nginx configure script is automatically called with the `--add-module=` option, pointing to where the module was cloned.

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
-n https://github.com/nginx/nginx.git/@release-1.0.0
# it all lives in /opt/nginx
-o --prefix=/opt/nginx
-o --with-http_ssl_module # HTTPS
-o --with-debug # helps us debug location directive errors
# Use the OpenSSL in /opt
-o --with-cc-opt=-I/opt/openssl/include
-o --with-ld-opt=-L/opt/openssl/lib
```
