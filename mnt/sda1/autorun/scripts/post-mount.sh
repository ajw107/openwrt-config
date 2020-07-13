#!/bin/sh

# Sleep to avoid conflicts with ReadyCLOUD
STALL=5
echo sleeping for ${STALL}s
for i in $(seq ${STALL} -1 1)
do
    sleep 1
    echo -n ${i}...
done

echo Setting up system variables
export PATH=/opt/bin:/opt/sbin:/opt/usr/bin:/opt/usr/sbin:${PATH}
export TERMINFO=/opt/share/terminfo
export TERM=xterm-256color
#vt100
alias ll='ls -al'
alias psgrep='ps | grep -i'

echo -e "echo Setting up system variables\nexport PATH=/opt/bin:/opt/sbin:/opt/usr/bin:/opt/usr/sbin:${PATH}\nexport TERM=xterm-256color\nalias ll='ls -al'\nalias psgrep='ps | grep -i'" | \
    tee -a /etc/profile

echo Setting up Entware
# Create symlinks to Entware if /ReadyCLOUD is installed
if [ -d /opt ]; then if [ ! -e /opt/bin ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/bin /opt/bin
		/bin/echo "Create link" > /tmp/entware.log
	fi

	if [ ! -e /opt/etc ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/etc /opt/etc
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/home ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/home /opt/home
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/lib ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/lib /opt/lib
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/root ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/root /opt/root
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/sbin ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/sbin /opt/sbin
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/share ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/share /opt/share
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/tmp ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/tmp /opt/tmp
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/usr ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/usr /opt/usr
		/bin/echo "Create link" >> /tmp/entware.log
	fi

	if [ ! -e /opt/var ]; then
		/bin/ln -sf /tmp/mnt/$1/entware/var /opt/var
		/bin/echo "Create link" >> /tmp/entware.log
	fi
else
	nocloud=$(/bin/config get nocloud)
	if [ "$nocloud" = "1" ]; then
		/bin/ln -sf /tmp/mnt/$1/entware /tmp/opt
		if [ ! -e /opt ]; then
			/bin/ln -sf /tmp/opt /opt
		fi
	elif [ -e /opt ]; then
		/bin/rm -f /opt
		if [ -e /overlay/opt ]; then
			/bin/rm -f /overlay/opt
		fi
		exit 1
	fi
fi

echo Setting up swap
# Enable swap if swap file exists in /mnt/sd*/
SWAP=0
for SWAP in /tmp/mnt/sd[a-z]*/swap
do
    if [[ -f $SWAP ]]
    then
#        SWAP=1
        break
    fi
done

if [ ! $SWAP = "0" ]; then
	/sbin/swapon $SWAP
fi

echo Setting up ssh
if [ ! -d /root/.ssh ]
then
    mkdir /root/.ssh
fi

if [ ! -e /root/.ssh/authorized_keys ]
then
    cp /mnt/${1}/authorized_keys /root/.ssh/
fi

echo Starting Entware
# Start optware services if /opt is linked
if [ -x /opt/etc/init.d/rc.unslung ]; then

	# Start optware services
	/opt/etc/init.d/rc.unslung start
fi

#setting up dnsmasq as dns
#should check for mydns, /tmp/resolve.conf and /opt/etc/dnsmasq.conf existance and copy them from /mnt/sda if not found
/opt/bin/bash /mnt/sda1/mydns 2>&1 | tee /dnsmasq_replace.log
