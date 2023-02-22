# jump-proxy

This is a very simple POSIX shell script that allows you to create multiple SSH socks tunnels to different servers behind a socks5 load-balancer. Such as [dispatch-proxy](https://github.com/alexkirsz/dispatch-proxy). The script checks the ports every 3 seconds and reconnect the SSH connection if it's dropped.

## Usage

The script needs some config. Configure your Iranian SSH servers as jump servers in the script. A jump server will be used to double port forward the connection from an Iranian server to foreign ones. This keeps your connection even during internet blackout. A jump server will be randomly selected every time the script runs and jot needs to be installed to be used to generate random numbers. Server names are Host declarations in ssh_config.
 
```sh
jump_server=`jot -r 1 1 3`
case $jump_server in
1)
	jump="jump1"
	;;
2)
	jump="jump2"
	;;
3)
	jump="jump3"
	;;
esac
```

The connections that get randomly selected are in connect_socks().
The configuration for SSH jump to a foreign server is declared like this. 

ip:port is SSH ip and port of a foreign server and local_port should be a free port on your localhost to be used as a forwarder port.
```sh
ssh_jump "ip:port" "local_port"
```
Use this line to directly tunnel to a sever without jumping server.
```sh
$ssh -D $socks_ip:$socks_port server2
```
This is an example of 4 different SSH pathways. Two jumped from Iran to outside and two connected directly to outside servers. Just to ensure availability.  
```sh
connect_socks ()
{
    server=`jot -r 1 1 4`
	case $server in
	1)
		ssh_jump "167.235.225.130:22" "9998"
		;;
	2)
		$ssh -D $socks_ip:$socks_port server1
		;;
	3)
		ssh_jump "176.9.175.100:22" "9997"
		;;
	4)
		$ssh -D $socks_ip:$socks_port server2
		;;
	esac
}
```

Run the script like this every minute using cronjobs. The script exits after a minute. Create as many tunnels as you wish.
```
*	*	*	*	*	/usr/local/bin/proxy.sh 127.0.0.1 10000 
*	*	*	*	*	/usr/local/bin/proxy.sh 127.0.0.1 10001
```

You can add these configs to your SSH_CONFIG(5) to ensure the connection restart quickly when they get dropped.
```
ServerAliveInterval 1
ServerAliveCountMax 3
```
