#!/bin/sh
TOGGLTOKEN=TODO
TOGGLAPI="https://www.toggl.com/api/v8/"
TOGGLCN="\"created_with\":\"togglebash\""
TOGGLPROJECTID=TODO
FULLNAME=TODO
JOBTITLE=TODO
HIPCHAT_EMAIL=TODO
HIPCHAT_MENTION_NAME=TODO
HIPCHAT_AUTH_TOKEN=TODO
HIPCHAT_TIMEZONE=Pacific/Honolulu

__toggl_call() {
  curl -s -u "$TOGGLTOKEN:api_token" \
  -H 'Content-type: application/json' \
  "$3" -X $1 "$TOGGLAPI$2"
}

__toggl_get() {
  __toggl_call 'GET' "$1"
}

__toggl_post() {
  __toggl_call 'POST' "$1" "-d $2"
}

__toggl_put() {
  __toggl_call 'PUT' "$1"
}

__toggl_start() {
  __toggl_post 'time_entries/start' \
     "{\"time_entry\":{\"pid\":$TOGGLPROJECTID,\"description\":\"$1\",$TOGGLCN}}" |
     python -m json.tool
}

__toggl_me() {
  __toggl_get 'me' | python -m json.tool
}

__toggl_entries() {
  __toggl_get 'time_entries'
}

__toggl_current() {

  if [ -s ~/.toggl/current_task ]; then jshon < ~/.toggl/current_task;
  else
    local last_task=$(__toggl_get 'time_entries' | jshon -e 4);
    if [[ -z $(echo $last_task | jshon -e "stop") ]]; then
      echo "No Current Task Running";
    else
      echo $last_task > ~/.toggl/current_task;
      echo $last_task | jshon;
    fi
   fi

}

__toggl_interrupt() {
  if [[ -f ~/.toggl/current_task ]]; then
      mv ~/.toggl/current_task ~/.toggl/interrupted_task
    fi
    __toggl_start %1
}

__toggl_stop() {
  __toggl_put "time_entries/$1/stop" > ~/.toggl/stopped_task
  if [[ -s ~/.toggl/stopped_task ]]; then rm ~/.toggl/current_task; fi
}

__toggl_pause() {
  local id=$(__toggl_current | jshon -e "data" -e "id")
  if [[ -f ~/.toggl/current_task ]]; then
    mv ~/.toggl/current_task ~/.toggl/paused_task
  fi
  __toggl_stop $id
}

__toggl_resume() {
  #if [[ -s ~/.toggl/paused_task ]]; then local id=$(jshon -e "data" -e "id" < ~/.toggl/paused_task);
  #else if [[ -s ~/.toggl/interrupted_task ]]; then local id=$(jshon -e "data" -e "id" ~/.toggl/interrupted_task);
  #else local id=0; fi
  return 0;
}

# Post to toggl
__toggl_start "$*"

HIPCHATSTATUS="`echo $* | cut -c1-50`"
# Post to hipchat
curl -s \
  -X PUT \
  -H 'Content-type: application/json' \
  -d "{\"name\":\"$FULLNAME\",\"title\":\"$JOBTITLE\",\"timezone\":\"$HIPCHAT_TIMEZONE\",\"email\":\"$HIPCHAT_EMAIL\",\"mention_name\":\"$HIPCHAT_MENTION_NAME\",\"presence\":{\"show\":null,\"status\":\"$HIPCHATSTATUS\"}}" \
  "https://api.hipchat.com/v2/user/$HIPCHAT_EMAIL?auth_token=$HIPCHAT_AUTH_TOKEN"
