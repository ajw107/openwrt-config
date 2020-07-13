#!/usr/bin/env bash

. "${PWD}/commonfunctions"

declare -r PROG_NAME="xpr3-build-script"
declare -r PROG_VER="1.0"
declare -r AUTHOR="Alex Wood"
declare -r AUTHOR_EMAIL="alex@alex-wood.org.uk"

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.8.1
# ARG_OPTIONAL_BOOLEAN([clean],[c],[Cleans old build files before building to make sure old files don't halt the build process.  As a result build time is substantially long (the toolchain, linux, utils, everything is rebuilt],[on])
# ARG_OPTIONAL_BOOLEAN([renew_config],[r],[Replace any current configuration (.config) with the default one.  WARNING: This will undo any changes you have made using make menuconfig.],[on])
# ARG_OPTIONAL_BOOLEAN([update],[u],[Update the git repo (for OpenWRT and DAWN) and update and install the feeds.  Nano is also repatched and DAWN is relinked.  WARNING: As this bring the code up to date with the 'bleeding 'edge' of OpenWRT some builds may fail until a fix has been commited to the OpenWRT/Feeds/DAWN repos],[on])
# ARGBASH_SET_DELIM([ =])
# ARG_OPTION_STACKING([getopt])
# ARG_RESTRICT_VALUES([no-local-options])
# ARG_HELP([Compiles a OpenWRT Snapshop image (i.e. using latest code from git) suitable suitable for a Xiaomi Mi Router 3 Pro being used in Wireless Access Point mode only.  Change *.config files to change router type; Change 99_uci_defaults, mac_hostnames and secrets in files to change how it is configured])
# ARG_VERSION([echo "${PROG_NAME} v${PROG_VER} by ${AUTHOR} (${AUTHOR_EMAIL})"])
# ARGBASH_SET_INDENT([    ])
# ARGBASH_GO

# [ <-- needed because of Argbash
infoText "MAIN CODE START [${PROG_NAME} v${PROG_VER} by ${AUTHOR} (${AUTHOR_EMAIL})]" ${INFO_TEXT_MISC_NO_DOTS}
GIT_ROOT="${HOME}/git"
OPENWRT_ROOT="${GIT_ROOT}/openwrt"
DAWN_ROOT="${GIT_ROOT}/DAWN"
DAWN_FEED_LINK="${OPENWRT_ROOT}/feeds/packages/net/dawn/git-src"
CONFIG_DIRECTORY="${PWD}"

pushd "${OPENWRT_ROOT}"

infoText "Build System Prerequisites/Dependancies" ${INFO_TEXT_INSTALL}
sudo apt install -y subversion g++ zlib1g-dev build-essential git python python3 python3-distutils libncurses5-dev gawk gettext unzip file libssl-dev wget libelf-dev ecj fastjar java-propose-classpath intltool util-linux asciidoc binutils 

if [ "${_arg_update}" = "on" ]
then
    infoText "Updating from remote Git Repo" ${INFO_TEXT_MISC}
    git pull
fi
if [ "${_arg_clean}" = "on" ]
then
    infoText "Deleting files from previous builds" ${INFO_TEXT_MISC}
    sudo rm -rf "${OPENWRT_ROOT}/tmp" "${OPENWRT_ROOT}/staging_dir" "${OPENWRT_ROOT}/feeds" "${OPENWRT_ROOT}/dl" "${OPENWRT_ROOT}/build_dir" "${OPENWRT_ROOT}/bin"
fi
if [ "${_arg_update}" = "on" ]
then
    infoText "Updating Feeds" ${INFO_TEXT_MISC}
    "${OPENWRT_ROOT}/scripts/feeds" update -a
    infoText "Patch to Nano" ${INFO_TEXT_APPLY}
    patch --verbose --unified --input "${CONFIG_DIRECTORY}/nano-tiny-to-full.patch" "${OPENWRT_ROOT}/feeds/packages/utils/nano/Makefile"
    infoText "Updating DAWN from git repo" ${INFO_TEXT_MISC}
    pushd "${DAWN_ROOT}"
    git pull
    popd
    infoText "Linking DAWN" ${INFO_TEXT_MISC}
    if $(sudo test -e "${DAWN_FEED_LINK}")
    then
        if ! $(sudo test -L "${DAWN_FEED_LINK}")
        then
            #something is there, and it's not a link. remove it
            rm -rf "${DAWN_FEED_LINK}"
            ln -s "${DAWN_ROOT}/.git" "${DAWN_FEED_LINK}"
        fi
    else
        ln -s "${DAWN_ROOT}/.git" "${DAWN_FEED_LINK}"
    fi
    infoText "Feeds" ${INFO_TEXT_INSTALL}
    "${OPENWRT_ROOT}/scripts/feeds" install -a
fi
if [ "${_arg_renew_config}" = "on" ]
then
    #infoText "Default Config"  ${INFO_TEXT_DOWNLOAD}
    #wget https://downloads.openwrt.org/snapshots/targets/ramips/mt7621/config.buildinfo -O .config
    #use sed to remove multiple device parts of the config
    infoText "Default Config" ${INFO_TEXT_COPY} #comment out if above used
    cp "${CONFIG_DIRECTORY}/defaultdiff.config" "${OPENWRT_ROOT}/.config" #comment out if above used
    infoText "Xiaomi Router Pro 3 Config" ${INFO_TEXT_APPLY}
    cat "${CONFIG_DIRECTORY}/xrp3.config" >> "${OPENWRT_ROOT}/.config"
    #infoText "Mesh Config" ${INFO_TEXT_APPLY}
    #cat "${CONFIG_DIRECTORY}/mesh.config" >> ""${OPENWRT_ROOT}/.config"
    infoText "Personal Config" ${INFO_TEXT_APPLY}
    cat "${CONFIG_DIRECTORY}/extras.config" >> "${OPENWRT_ROOT}/.config"
    infoText "Personal Default Settings" ${INFO_TEXT_APPLY}
    if $(sudo test -e "${OPENWRT_ROOT}/files")
    then
        sudo rm -rf "${OPENWRT_ROOT}/files"
    fi
    cp -arp "${CONFIG_DIRECTORY}/files" "${OPENWRT_ROOT}/files"
    infoText "Creating Full Config and Final Checks" ${INFO_TEXT_MISC}
    make defconfig
fi
#Always give the option to make last minute changes
make menuconfig
if [ "${_arg_clean}" = "on" ]
then
    infoText "Cleaning Build directories" ${INFO_TEXT_MISC}
    make clean
fi
if [ "${_arg_update}" = "on" ]
then
    infoText "Packages" ${INFO_TEXT_DOWNLOAD}
    make download
fi

infoText "Compiling Image" ${INFO_TEXT_MISC}
make -j$(($(nproc)+2)) world
retVal=$?
if [ "${retVal}" == "0" ]
then
    infoText "Image is available at: [$(find "${OPENWRT_ROOT}/bin" -iname "*sysupgrade.bin")]" ${INFO_TEXT_MISC_NO_DOTS}
else
    warnText "The image failed to compile, view the warnings above, or cd to ["${OPENWRT_ROOT}"] and run make -j1 V=s"
fi
popd

# ] <-- needed because of Argbash
