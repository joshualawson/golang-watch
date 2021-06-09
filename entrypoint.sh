#!/bin/bash

# create directory for Delve logs, we use it to know that Delve
# debugger is running
mkdir -p /tmp/dlv_log

runBuild() {
  echo Running build

  # create directory and file to

  touch /tmp/dlv_log/output.log

  # run build with debug
  if [ "${RUN_ON_START:-true}" = true ]; then
    dlv --listen=:40000 --headless=true --continue --accept-multiclient --api-version=2 exec \
     /build | tee -a /tmp/dlv_log/output.log &
  else
    dlv --listen=:40000 --headless=true --api-version=2 exec \
     /build | tee -a /tmp/dlv_log/output.log &
  fi

  # wait for Delve to modify log files - means /build is running
  inotifywait -e MODIFY /tmp/dlv_log/output.log &>/dev/null

  echo Delve PID: $(pidof dlv), Build PID: $(pidof build)
  pidof dlv > /tmp/dlv.pid
  pidof build > /tmp/build.pid
}

killRunningBuild() {
  if [ -f /tmp/dlv.pid ]
  then
    echo killing old Delve, PID: $(cat /tmp/dlv.pid)
    kill $(cat /tmp/dlv.pid)
    rm -f /tmp/dlv.pid
  fi

  if [ -f /tmp/build.pid ]
  then
    echo killing old build, PID: $(cat /tmp/build.pid)
    kill $(cat /tmp/build.pid)
    rm -f /tmp/build.pid
  fi
}

buildBuild() {
  echo Building build
  go build -gcflags "all=-N -l" -o /build main.go
}

rerunBuild () {
  killRunningBuild
  buildBuild
  runBuild
}

lockBuild() {
  # check lock file existence
  if [ -f /tmp/build.lock ]
  then
    # waiting for the file to delete
    inotifywait -e DELETE /tmp/build.lock
  fi
  touch /tmp/build.lock
}

unlockBuild() {
  # remove lock file
  rm -f /tmp/build.lock
}

# build and run the build for the first time
buildBuild
runBuild

inotifywait -e MODIFY -r -m /src |
  while read path action file; do
    lockBuild
      ext=${file: -3}
      if [[ "$ext" == ".go" ]] || [[ "$ext" == ".cfg" ]]; then
        echo File changed: $file
        rerunBuild
      fi
    unlockBuild
  done
