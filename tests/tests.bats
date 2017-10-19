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

@test "Build from an existing cloned source directory" {
  builddir="$(mktemp -d)"
  run ./build-nginx -s "$builddir" -c
  run ./build-nginx -s "$builddir" -b
  [ -d "$builddir/nginx-master" ]
  [ $status -eq 0 ]
  [ -f "$builddir/nginx-master/objs/nginx" ]
}
