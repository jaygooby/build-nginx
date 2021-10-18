#!/usr/bin/env bats

@test "-h switch" {
  # skip
  run ./build-nginx -h
  [ $status -eq 0 ]
  [[ "$output" =~ "-h Help" ]]
}

@test "-? switch" {
  # skip
  run ./build-nginx -h
  [ $status -eq 0 ]
  [[ "$output" =~ "-h Help" ]]
}

@test "Invalid switch" {
  # skip
  run ./build-nginx -X

  [ $status -ne 0 ]
  [[ "$output" =~ "Invalid option" ]]
}

@test "Installing with -i switch" {
  # skip
  installdir="$(mktemp -d)"
  run ./build-nginx -i -o --prefix="$installdir"
  [ $status -eq 0 ]
  [[ "$output" =~ "cp objs/nginx '$installdir/sbin/nginx'" ]]
}

@test "Clone nginx master" {
  skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -c
  [ $status -eq 0 ]
  [ -d "$builddir/nginx-master" ]
}

@test "Clone nginx at specific version" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -n https://github.com/nginx/nginx.git@release-1.12.2
  [ $status -eq 0 ]
  [ -d "$builddir/nginx-release-1.12.2" ]
  run "$builddir/nginx-release-1.12.2/objs/nginx" -V
  [[ "$output" =~ "nginx version: nginx/1.12.2" ]]
}

@test "Build from an existing cloned source directory" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -c
  run ./build-nginx -s "$builddir" -b
  [ -d "$builddir/nginx-master" ]
  [ $status -eq 0 ]
  [ -f "$builddir/nginx-master/objs/nginx" ]
}

@test "Clone and build nginx with a 3rd party module from a specific branch" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -m https://github.com/jaygooby/build-nginx.git@hello-world-module
  [ $status -eq 0 ]
  [[ "$output" =~ "objs/addon/build-nginx-hello-world-module/ngx_http_hello_world_module.o" ]]
}

@test "nginx with openssl 1.0.2l" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -d https://github.com/openssl/openssl.git@OpenSSL_1_0_2l
  [ $status -eq 0 ]
  run "$builddir/nginx-master/objs/nginx" -V
  [[ "$output" =~ "--with-openssl=" ]]
}

@test "nginx with openssl and zlib" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -d https://github.com/openssl/openssl.git -d https://github.com/madler/zlib.git
  [ $status -eq 0 ]
  run "$builddir/nginx-master/objs/nginx" -V
  [[ "$output" =~ "--with-openssl=" ]]
  [[ "$output" =~ "--with-zlib=" ]]
}

@test "Build nginx from an archive URL" {
  # skip
  builddir="$(mktemp -d)"
  echo $builddir >&2
  run ./build-nginx -s "$builddir" -n http://nginx.org/download/nginx-1.13.6.tar.gz
  [ $status -eq 0 ]
  [ -d "$builddir/http___nginx_org_download_nginx-1.13.6" ]
  run "$builddir/http___nginx_org_download_nginx-1.13.6/objs/nginx" -V
  [[ "$output" =~ "nginx version: nginx/1.13.6" ]]
}

@test "Build nginx from an archive URL and with a module from a git repo URL" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -n http://nginx.org/download/nginx-1.13.6.tar.gz -m https://github.com/jaygooby/build-nginx.git@hello-world-module
  [ $status -eq 0 ]
  [ -d "$builddir/http___nginx_org_download_nginx-1.13.6" ]
  run "$builddir/http___nginx_org_download_nginx-1.13.6/objs/nginx" -V
  [[ "$output" =~ "nginx version: nginx/1.13.6" ]]
}

@test "Specify a module config folder using a git url" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -m https://github.com/nbs-system/naxsi.git,naxsi_src
  [ $status -eq 0 ]
  [[ "$output" =~ "objs/addon/naxsi_src/naxsi_runtime.o" ]]
}

@test "Specify a module config folder using an archive url" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -m https://github.com/nbs-system/naxsi/archive/0.55.3.tar.gz,naxsi_src
  [ $status -eq 0 ]
  [[ "$output" =~ "objs/addon/naxsi_src/naxsi_runtime.o" ]]
}

@test "Use just a config file" {
  # skip
  builddir="$HOME/.build-nginx"
  run ./build-nginx -k tests/test-config
  [ $status -eq 0 ]
  run "$builddir/nginx-branches/stable-1.12/objs/nginx" -V
  [[ "$output" =~ "--with-http_stub_status_module" ]]
  [[ "$output" =~ "--with-pcre" ]]
}

@test "Use a config file with additional commandline options" {
  # skip
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -k tests/test-config -m https://github.com/jaygooby/build-nginx.git@hello-world-module
  [ $status -eq 0 ]
  [[ "$output" =~ "objs/addon/build-nginx-hello-world-module/ngx_http_hello_world_module.o" ]]
  run "$builddir/nginx-branches/stable-1.12/objs/nginx" -V
  [[ "$output" =~ "nginx version: nginx/1.12" ]]
  [[ "$output" =~ "--with-http_stub_status_module" ]]
  [[ "$output" =~ "--with-pcre" ]]
}
