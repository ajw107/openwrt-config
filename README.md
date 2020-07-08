# openwrt-config

My config files for the OpenWRT ROuter (at present being used as Wireless Access Points).  Includes 99_uci_defaults script which is an almost generic script that will config two routers as Access Points (called bedroom and living) and along with the secrets file will include passwords and passphrases and along with the mac_hostnames file will stop OpenWRT only outputting unrecognisable MAC addresses, and provde nice names for the devices.
- Made for Xiaomi Mi Router 3 Pro, but can be adpted for most routers.
- After install of firmware remember to log in to router on a browser and go to Network->Wireless to let Luci do it's thing with wireless naming

The files should be organised in this hierachy:
```
📦${HOME}
 ┣📂bin
 ┃ ┗📜commonfunctions (copied from git repo github.com:ajw107/openwrt-config)
 ┣📂git
 ┃ ┣📂openwrt (cloned from git repo github.com:openwrt/openwrt)
 ┃ ┣📂openwrt-config (cloned from git repo github.com:ajw107/openwrt-config)
 ┃ ┃ ┣📜defaultdiff.config (Holds OpenWRT default values that aren't covered by xrp3.config)
 ┃ ┃ ┣📜extras.config (Holds extra packages I personally like on my routers)
 ┃ ┃ ┣📜mesh.config (Holds configs specific to using a mesh network [WARNING: Very much a work in progress)
 ┃ ┃ ┣📜nano-tiny-to-full.patch (Converts the usual Nano Makefile to build the full version of nano for colour, syntax highlighting support, etc)
 ┃ ┃ ┣📜upload-firmware (Script produced from the .m4 file via ArgBash)
 ┃ ┃ ┣📜upload-firmware.m4 (Original file that creates the script using ArgBash)
 ┃ ┃ ┣📜xrp3-build-script (Script produced from the .m4 file via ArgBash)
 ┃ ┃ ┣📜xrp3-build-script.m4 (Original file that creates the script using ArgBash)
 ┃ ┃ ┣📜xrp3.config (Hold config values specifi to the Xiaomi Mi Router 3 Pro)
 ┃ ┃ ┗📂files
 ┃ ┃  ┣📜mac_hostnames (You need to create this.  Holds useful names to use instead of plain mac address in the OpenWRT UI.  See mac_hostnames-example to make your own)
 ┃ ┃  ┣📜secrets (You need to create this.  Holds sensitive values you may not want in your script, such as Wifi Passphrase.  See secrets-example to make your own)
 ┃ ┃  ┣📂etc
 ┃ ┃  ┃ ┣📂dropbear
 ┃ ┃  ┃ ┃ ┗📜authorized_keys  (You need to create this by adding any public keys you want to use to this file)
 ┃ ┃  ┃ ┗📂uci-defaults
 ┃ ┃  ┃ ┃ ┗📜99_apply_defaults (The main setup script that sets the router up automatically for you with the help of the secrets and mac_hostnames files)
 ┃ ┃  ┃ ┗📜nanorc (One is supplied, but you can use your own)
 ┃ ┃  ┗📂usr
 ┃ ┃    ┗📂bin
 ┃ ┃       ┗📜set_password.lua (A helper script that sets the Router Login password)
 ┃ ┗📂DAWN (cloned from git repo github.com:berlin-open-wireless-lab/DAWN)
 ┗📂secrets
   ┗📜commonfunctions_secrets (copied from git repo github.com:ajw107/openwrt-config)
```
TODO:
recover and upload:
build script
upload script
