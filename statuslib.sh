#!/bin/sh
# Copyright (C) 2021 Wesley Tanaka

DIRNAME=$(dirname $0)
CONF_FILE_PATH=~/.config/status/conf.sh

__parse_conf() {
  if [ -r "$CONF_FILE_PATH" ]; then
    . "$CONF_FILE_PATH"
  else
    echo "Cannot locate $CONF_FILE_PATH"
  fi
}

__status_start() {
  __parse_conf
  for svc in $STATUS_SERVICES; do
    . "$DIRNAME"/"$svc"lib.sh
    __"$svc"_start "$@"
  done
}

__status_stop() {
  __parse_conf
  for svc in $STATUS_SERVICES; do
    . "$DIRNAME"/"$svc"lib.sh
    __"$svc"_stop "$@"
  done
}

__status_away() {
  __parse_conf
  for svc in $STATUS_SERVICES; do
    . "$DIRNAME"/"$svc"lib.sh
    __"$svc"_away "$@"
  done
}
