#!/bin/sh
# Copyright (C) 2021 Wesley Tanaka

TOGGL_API="https://www.toggl.com/api/v8/"
TOGGL_CN="\"created_with\":\"togglebash\""

__toggl_call() {
  curl -s -u "${TOGGL_TOKEN}:api_token" \
  -H 'Content-type: application/json' \
  "$3" -X $1 "${TOGGL_API}$2"
}

__toggl_post() {
  __toggl_call 'POST' "$1" "-d $2"
}

__toggl_get() {
  __toggl_call 'GET' "$1"
}

__toggl_put() {
  __toggl_call 'PUT' "$1"
}

__toggl_me() {
  __toggl_get 'me' | python -m json.tool
}

__toggl_entries() {
  __toggl_get 'time_entries'
}

__toggl_current() {
  LAST_TASK=$(__toggl_get 'time_entries' | jq '.[length -1]')
  if echo "$LAST_TASK" | jq -e '.stop' > /dev/null; then
    :
  else
    echo "$LAST_TASK" | jq .
  fi
}

__toggl_start() {
  __toggl_post 'time_entries/start' \
     "{\"time_entry\":{\"pid\":$TOGGL_PROJECT_ID,\"description\":\"$*\",$TOGGL_CN}}" |
     python -m json.tool
}

__toggl_stop() {
  ID=$(__toggl_current | jq -e .id)
  if [ -z "$ID" ]; then
    return 1
  else
    __toggl_put "time_entries/${ID}/stop" |
        jq '.[] | {id, stop}'
  fi
}
