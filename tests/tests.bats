#!/usr/bin/env bats

@test "-h switch" {
  run ./build-nginx -h
  [ $status -eq 0 ]
  [[ "$output" =~ "-h Help" ]]
}

@test "-? switch" {
  run ./build-nginx -h
  [ $status -eq 0 ]
  [[ "$output" =~ "-h Help" ]]
}

@test "Invalid switch" {
  run ./build-nginx -X

  [ $status -ne 0 ]
  [[ "$output" =~ "Invalid option" ]]
}

@test "Clone nginx master" {
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -c
  [ $status -eq 0 ]
  [ -d "$builddir/nginx-master" ]
}

@test "Clone nginx at specific version" {
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -n https://github.com/nginx/nginx.git@release-1.12.2
  [ $status -eq 0 ]
  [ -d "$builddir/nginx-release-1.12.2" ]
  run "$builddir/nginx-release-1.12.2/objs/nginx" -V
  [[ "$output" =~ "nginx version: nginx/1.12.2" ]]
}

@test "Build from an existing cloned source directory" {
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -c
  run ./build-nginx -s "$builddir" -b
  [ -d "$builddir/nginx-master" ]
  [ $status -eq 0 ]
  [ -f "$builddir/nginx-master/objs/nginx" ]
}

@test "Clone and build nginx with a 3rd party module from a specific branch" {
  run ./build-nginx -m https://github.com/jaygooby/build-nginx.git@hello-world-module
  [ $status -eq 0 ]
  [[ "$output" =~ "objs/addon/build-nginx-hello-world-module/ngx_http_hello_world_module.o" ]]
}
