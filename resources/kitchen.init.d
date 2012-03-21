#!/bin/bash

KITCHEN_PATH=_KITCHEN_PATH_
PID_FILE=/var/run/kitchen.pid

function start {
    cd $KITCHEN_PATH
    rm -rf tmp/*
    ./script/rails server -e production &>/dev/null &
    RAILS_PID=$(ps ax|grep "rails server"|grep -v grep|awk '{print $1}')
    echo $RAILS_PID > $PID_FILE
    echo "Kitchen started"
}

function stop {
    #RAILS_PID=$(cat $PID_FILE)
    RAILS_PID=$(ps ax|grep "rails server"|grep -v grep|awk '{print $1}')
    kill -9 $RAILS_PID
    rm -f $RAILS_PID
    echo "Kitchen stopped"
}

case $1 in
	"start")
		start
	;;
	"stop")
		stop
	;;
	"restart")
		stop
		start
		echo "Kitchen restarted"
	;;
esac
