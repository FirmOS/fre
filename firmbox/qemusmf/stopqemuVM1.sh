PIDFILE=/var/run/qemuVM1.pid
QMP_SOCKET=/var/run/qmp-sockVM1;

QMP_SHUTDOWN='{ "execute": "qmp_capabilities" }{ "execute": "system_powerdown" }'
TIMEOUT_SHUTDOWN=60
TIMEOUT_TERMINATE=30
PID=`cat "$PIDFILE"`
#echo "PID: $PID"

if [ $PID -eq "" ] ; then
  echo "no pid" 
  exit 0
fi  

#PID=17575
ps -p $PID >/dev/null 2>&1
result=$?
#echo $result

if [ $result -ne 0 ] ; then
  echo "no process"
  exit 0
fi

echo "$QMP_SHUTDOWN" | nc -U $QMP_SOCKET

COUNTER=0
result=0
until [ $result -ne 0 ]; do
  ps -p $PID >/dev/null 2>&1
  result=$?
  sleep 1
  echo "waiting for shutdown $COUNTER $pid"
  COUNTER=`expr $COUNTER + 1`
  if [ "$COUNTER" -gt "$TIMEOUT_SHUTDOWN" ]; then
    break
  fi
done

ps -p $PID >/dev/null 2>&1
result=$?
if [ $result -ne 0 ]; then
  exit 0
fi

echo "terminating" 

kill -TERM $PID

COUNTER=0
result=0
until [ $result -ne 0 ]; do
  ps -p $PID >/dev/null 2>&1
  result=$?
  sleep 1
  echo "waiting for termination $COUNTER $pid"
  COUNTER=`expr $COUNTER + 1`
  if [ "$COUNTER" -gt "$TIMEOUT_TERMINATE" ]; then
    break
  fi
done

ps -p $PID >/dev/null 2>&1
result=$?
if [ $result -ne 0 ]; then
  exit 0
fi

echo "killing"
kill -KILL $PID
rm $PIDFILE
exit 0



