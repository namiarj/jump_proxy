#!/bin/sh

jump_server=`jot -r 1 1 2`
case $jump_server in
1)
	jump="server1"
	;;
2)
	jump="server2"
	;;
esac

ssh="ssh -i ~/.ssh/id_nopass -f -N"

end_time=$(( `date +%s` + 60 ))

log ()
{
	time=`date +%H:%M:%S`
	echo "$socks_ip:$socks_port [$time] $1"
}

check_port ()
{
	nc -z 127.0.0.1 $1 2> /dev/null
	return $?
}

ssh_jump ()
{
	if ! check_port $2
	then
		log "SSH jump server on port $2"
		$ssh -L $2:$1 $jump
	fi
	log "$1 tunnel"
	$ssh -p $2 -D $socks_ip:$socks_port root@127.0.0.1
}

connect_socks ()
{
	server=`jot -r 1 1 2`
	case $server in
	1)
		ssh_jump "1.1.1.1" "9998"
		;;
	2)
		log "tunnel on $socks_ip:$socks_port"
		$ssh -D $socks_ip:$socks_port server3 
		;;
	esac
}

if [ "$#" -ne 2 ]
then
	echo "usage: $0 socks_ip socks_port"
	exit 1
fi

socks_ip=$1
socks_port=$2

random=`jot -r 1 0 8`
sleep 0.$random

if ! check_port 10010
then
	go-dispatch-proxy -lhost 0.0.0.0 -lport 10010 -tunnel 127.0.0.1:10000 127.0.0.1:10001 127.0.0.1:10002 127.0.0.1:10003
fi

while [ `date +%s` -lt $end_time ]
do
	if ! check_port $socks_port
	then
		connect_socks
	fi
	timeout 10 ktrigger ~/.ssh/sessions/ true
done
