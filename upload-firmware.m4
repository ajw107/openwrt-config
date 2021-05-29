#!/usr/bin/env bash

. "${PWD}/commonfunctions"

declare -r BEDROOM_AP_IP="192.168.16.3"
declare -r LIVING_AP_IP="192.168.16.4"
declare -r FIRMWARE_LOCATION="${HOME}/git/openwrt/bin/targets/ramips/mt7621"
declare -r KNOWN_HOSTS_FILE="${HOME}/.ssh/known_hosts"
declare -r FIRMWARE_MATCH_PATTERN="*sysupgrade.bin"
declare -r UPLOADED_FIRMWARE_FILENAME="/sysupgrade.bin"
declare -r -i ERROR_NO_TARGET_SUPPLIED=101
declare -r -i ERROR_MULTIPLE_FIRMWARES_FOUND=102
declare -r PROG_NAME="uploadFirmware"
declare -r PROG_VER="1.0"
declare -r AUTHOR="Alex Wood"
declare -r AUTHOR_EMAIL="alex@alex-wood.org.uk"
declare _PRINT_HELP=no

#
# This is a positional arguments-only example of Argbash potential
#
# ARG_HELP([Uploads a firmware file to the router and applies it.])
# ARG_VERSION([echo "${PROG_NAME} v${PROG_VER} by ${AUTHOR} (${AUTHOR_EMAIL})"])
# ARG_VERBOSE([])
# ARG_POSITIONAL_SINGLE([target],[Router to update firmware of])
# ARG_TYPE_GROUP_SET([routers],[ROUTER],[target],[bedroom,Bedroom,living,Living])
# ARGBASH_SET_INDENT([    ])
#
#
#
#
# ARGBASH_GO()
# [ <-- needed because of Argbash


infoText "Main Code Start[${PROG_NAME} v${PROG_VER} by ${AUTHOR} (${AUTHOR_EMAIL})]" ${INFO_TEXT_MISC_NO_DOTS}

#get the right ip
case "${_arg_target}" in
    "bedroom"|"Bedroom")
        IP="${BEDROOM_AP_IP}"
        ;;
    "living"|"Living")
        IP="${LIVING_AP_IP}"
        ;;
    *)
        errorText "ERROR: incorrect target supplied. Should be either bedroom or living, you supplied [$@]"
        _PRINT_HELP=yes die "ERROR: incorrect target supplied. Should be either bedroom or living, you supplied [$@]" ${ERROR_BAD_ARGUMENT}
        ;;
esac

#Remove the old known hosts value for the router as it will have changed with the firmware update
ssh-keygen -f "${KNOWN_HOSTS_FILE}" -R "${IP}" &>/dev/null
#${SSH_KEYGEN} -f "${KNOWN_HOSTS_FILE}" -R "${IP}" &>/dev/null
firmwareFile=$(find "${FIRMWARE_LOCATION}" -iname "${FIRMWARE_MATCH_PATTERN}")
#firmwareFile=$(${FIND} "${FIRMWARE_LOCATION}" -iname "${FIRMWARE_MATCH_PATTERN}")

if [ "$(echo "${firmwareFile}" | wc -l)" -gt 1 ]
then
    errorText "ERROR: Multiple sysupgrade files found, please remove all but the one you want from [${FIRMWARE_LOCATION}]"
    _PRINT_HELP=no die "ERROR: Multiple sysupgrade files found, please remove all but the one you want from [${FIRMWARE_LOCATION}]" ${ERROR_MULTIPLE_FIRMWARES_FOUND}
fi

if [ "$(echo "${firmwareFile}" | wc -l)" -lt 1 ]
then
    errorText "ERROR: No sysupgrade files found, please check one exists in [${FIRMWARE_LOCATION}]"
    _PRINT_HELP=no die "ERROR: No sysupgrade files found, please check one exists in [${FIRMWARE_LOCATION}]" ${ERROR_FILE_MISSING}
fi

infoText "Uploading firmware" ${INFO_TEXT_MISC}
echo -e "yes\n" | scp "${firmwareFile}" "${IP}:${UPLOADED_FIRMWARE_FILENAME}"
#${SCP} "${firmwareFile}" "${IP}:${UPLOADED_FIRMWARE_FILENAME}"
infoText "firmware" ${INFO_TEXT_APPLY}
ssh "${IP}" "sysupgrade -n ${UPLOADED_FIRMWARE_FILENAME}"
#${SSH} "${IP}" "sysupgrade -n -F ${UPLOADED_FIRMWARE_FILENAME}"
warnText "Please wait a few minutes for the firmware to update, then goto ${IP} in your browser and load Network->Wireless after login"

# ] <-- needed because of Argbash
