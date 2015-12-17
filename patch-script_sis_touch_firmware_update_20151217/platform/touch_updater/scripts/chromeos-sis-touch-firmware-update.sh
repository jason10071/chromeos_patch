#!bin/sh

. /usr/share/misc/shflags
. /opt/google/touch/scripts/chromeos-touch-common.sh

# v1

# consoletool path
CONSOLETOOL_DIR=/usr/sbin
GET_FIRMWARE_ID=${CONSOLETOOL_DIR}/getFirmwareId
UPDATE_FW=${CONSOLETOOL_DIR}/updateFW

# fwbin pathi
FW_DIR="/lib/firmware"
FW_MASTER_LINK_NAME="sis_fw_M.bin"
FW_MASTER_LINK_PATH="${FW_DIR}/${FW_MASTER_LINK_NAME}"

# consoletool args settings
GET_FIRMWARE_ID_ARGS="-f=${FW_MASTER_LINK_PATH}"
UPDATE_FW_ARGS="${FW_MASTER_LINK_PATH} -b"

#
update_needed=${FLAGE_FALSE}
check_is_update_needed() {
	log_msg "Check is update needed ..."
	${GET_FIRMWARE_ID} ${GET_FIRMWARE_ID_ARGS}
	ret=$?

	if [ ${ret} -eq 0 ]; then
		# Firmware Id is the same
		log_msg "Firmware check done: not update needed"
                update_needed=${FLAGS_FALSE}
	elif [ ${ret} -eq 33 ]; then
		# Firmware Id is diffrtrnt
		log_msg "Firmware check done: update needed"
                update_needed=${FLAGS_TRUE}
	else
		# compare error occur
		log_msg "Firmware check done: compare fwbin error occur"
                update_needed=${FLAGS_FALSE}
	fi
}

update_firmware() {
	log_msg "Prepare to update firmware ..."
	${UPDATE_FW} ${UPDATE_FW_ARGS}
	ret=$?

	if [ ${ret} -eq 0 ]; then
                log_msg "Update FW succeded"
        else
                log_msg "Update FW fail"
        fi
}

main() {
	check_is_update_needed

        if [ "${update_needed}" = "${FLAGS_TRUE}" ]; then
		update_firmware
        fi
}

main

