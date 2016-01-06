#!bin/sh

. /usr/share/misc/shflags
. /opt/google/touch/scripts/chromeos-touch-common.sh

DEFINE_string 'device' '' "device name" 'd'
DEFINE_string 'firmware_name' '' "firmware name (in /lib/firmware)" 'n'

# Parse command line
FLAGS "$@" || exit 1
eval set -- "${FLAGS_ARGV}"

SIS_VID="0457"

# consoletool path
CONSOLETOOL_DIR=/usr/sbin
GET_FIRMWARE_ID=${CONSOLETOOL_DIR}/getFirmwareId
UPDATE_FW=${CONSOLETOOL_DIR}/updateFW

# fwbin path
FW_DIR="/lib/firmware"
#FW_MASTER_LINK_NAME="sis_fw_M.bin"
FW_MASTER_LINK_NAME=${FLAGS_firmware_name}
FW_MASTER_LINK_PATH="${FW_DIR}/${FW_MASTER_LINK_NAME}"

# consoletool args settings
SLAVE_NUM="--slaveNum=0"
GET_FIRMWARE_ID_ARGS="-f=${FW_MASTER_LINK_PATH} ${SLAVE_NUM}"
UPDATE_FW_ARGS="${FW_MASTER_LINK_PATH} -ba ${SLAVE_NUM}"

# func
update_needed=${FLAGE_FALSE}
check_is_update_needed() {
  log_msg "Check is update needed ..."
  tmp_log=$(${GET_FIRMWARE_ID} ${GET_FIRMWARE_ID_ARGS} $1)
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
    log_msg "${tmp_log}"
    update_needed=${FLAGS_FALSE}
  fi
}

# func
update_firmware() {
  log_msg "Prepare to update firmware ..."
  ${UPDATE_FW} ${UPDATE_FW_ARGS} $1
  ret=$?

  if [ ${ret} -eq 0 ]; then
    log_msg "Update FW succeeded"
  else
    log_msg "Update FW fail"
  fi
}

main() {
  if [ -z "${FLAGS_device}" ]; then
    die "Please specify a device using -d"
  fi

  local device_path="${FLAGS_device}"
  vid="$(echo ${device_path} | awk -F "[:]" '{print $2}')"

  if [ ${SIS_VID} = $vid ]; then
    local hidraw_path=$(ls ${device_path}/hidraw)

    # check is update needed
    check_is_update_needed "-n=${hidraw_path}"

    # prepare to update
    if [ "${update_needed}" = "${FLAGS_TRUE}" ]; then
      update_firmware "-n=${hidraw_path}"
    fi
  fi
}

main
