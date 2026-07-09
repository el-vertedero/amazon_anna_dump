#!/vendor/bin/sh
function FixupVerbose()
{
    #echo "##########Kayla FIXUP##########" > /dev/kmsg
    echo "$1" > /dev/kmsg
    #echo "##########Kayla FIXUP##########" > /dev/kmsg
}

KAYLAY_CHEYNE_EVT_BOARD_ID="00AA0002000M0022"
KAYLAY_FINDLAY_EVT_BOARD_ID="00AB0002000M0022"
#Kaine-T EVT device use wrong DVT stage board_id, so instead using config_name to check.
#KAYLAY_KAINE_EVT_BOARD_ID="00AC0002000M0022"
KAYLAY_KAINE_EVT_CONFIG_NAME="kaylaeu_nfevt"

KEY_SRC_PATH="/product/etc/"
KEY_WEBPLATFORM_PATH="/vendor/tvcertificate/webplatform/"
KEY_FVP_PATH="/vendor/tvcertificate/fvp/"

FVP_INTERMEDIATE_KEY_NAME="fvp_intermediate_key.bin"
FVP_INTERMEDIATE_CERT_NAME="intermediate.cert.pem"
FVP_CLIENT_KEY_NAME="client.key.pem"
FVP_CLIENT_CERT_NAME="client.cert.pem"
KEY_MD5SUM_NAME="FVP-files.md5sum"

BOARD_ID=`cat /proc/idme/board_id`
CONFIG_NAME=`cat /proc/idme/config_name`
REGION=`cat /proc/idme/region`

KYEU_982_CHECK_FLAG=/vendor/tvcertificate/fvp_kyeu982_fixup_done
KYEU_1015_CHECK_FLAG=/vendor/tvcertificate/fvp_kyeu1015_fixup_done

# Fixup for KYEU-982 and KYEU-1015
if [ $BOARD_ID == $KAYLAY_CHEYNE_EVT_BOARD_ID ] || [ $BOARD_ID == $KAYLAY_FINDLAY_EVT_BOARD_ID ] || [ $CONFIG_NAME == $KAYLAY_KAINE_EVT_CONFIG_NAME ]; then
	if [ "GB" == "$REGION" ]; then
		if [ -f $KYEU_982_CHECK_FLAG ]; then	
			FixupVerbose "[FIXUP]Fixup for KYEU-982 was already done"
		else
			FixupVerbose "[FIXUP]UK device detected"

			# Correct Selinux Context First, otherwise key copy or delete on "/vendor/tvcertificate/webplatform/" folder doesn't work
			mkdir -p ${KEY_WEBPLATFORM_PATH}
			ls_ret=`ls -dlZ ${KEY_WEBPLATFORM_PATH}`
			selinux_context=`echo $ls_ret|cut -d " " -F5`
			if [ "$selinux_context" != "u:object_r:tv_certificate_file:s0" ];then
				chcon u:object_r:tv_certificate_file:s0 ${KEY_WEBPLATFORM_PATH}
			fi

			#Update FVP Intermediate and Client certificates, do FVP re-provision if keys are not expected.
			fvpStatus=0
			intermediate_cert_pem_checksum=`cat ${KEY_SRC_PATH}${KEY_MD5SUM_NAME} | grep ${FVP_INTERMEDIATE_CERT_NAME} | awk '{print $1}'`
			cur_intermediate_cert_pem_checksum=`md5sum ${KEY_FVP_PATH}${FVP_INTERMEDIATE_CERT_NAME} | head -c 32`
			if [ "$intermediate_cert_pem_checksum" != "$cur_intermediate_cert_pem_checksum" ];then
				FixupVerbose "[FIXUP]intermediate_cert_pem_checksum md5sum check FAIL"
				fvpStatus=1
			fi
			client_cert_pem_checksum=`cat ${KEY_SRC_PATH}${KEY_MD5SUM_NAME} | grep ${FVP_CLIENT_CERT_NAME} | awk '{print $1}'`
			cur_client_cert_pem_checksum=`md5sum ${KEY_FVP_PATH}${FVP_CLIENT_CERT_NAME} | head -c 32`
			if [ "$client_cert_pem_checksum" != "$cur_client_cert_pem_checksum" ];then
				FixupVerbose "[FIXUP]client_cert_pem_checksum md5sum check FAIL"
				fvpStatus=1
			fi
			client_key_pem_checksum=`cat ${KEY_SRC_PATH}${KEY_MD5SUM_NAME} | grep ${FVP_CLIENT_KEY_NAME} | awk '{print $1}'`
			cur_client_key_pem_checksum=`md5sum ${KEY_FVP_PATH}${FVP_CLIENT_KEY_NAME} | head -c 32`
			if [ "$client_key_pem_checksum" != "$cur_client_key_pem_checksum" ];then
				FixupVerbose "[FIXUP]client_key_pem_checksum md5sum check FAIL"
				fvpStatus=1
			fi

			if [ $fvpStatus = 1 ];then	
				#Do re-provision
				# 1. delete old intermediate private key from secure storage if exist on device.
				intertaca_manual -c 23 
				if [ $? == 0 ] ; then
					intertaca_manual -d runtime 23
					if [ $? == 0 ] ; then
						FixupVerbose "[FIXUP]delete old FVP intermediate private key success"
					else
						FixupVerbose "[FIXUP]delete old FVP intermediate private key Failed"
					fi
				fi

				# 2. check FVP prviate key deletion status
				# 3. re-provision with new FVP key.
				# 4. check re-provision status. pass to update other certs and do backup.
				# 5. delete FVP private key.
				intertaca_manual -c 23
				if [ $? != 0 ]; then
					FixupVerbose "[FIXUP]check FVP key deletion success"
					
					cp ${KEY_SRC_PATH}${FVP_INTERMEDIATE_KEY_NAME} ${KEY_WEBPLATFORM_PATH}${FVP_INTERMEDIATE_KEY_NAME}
					intertaca_manual 23 1
					if [ $? == 0 ] ; then
						FixupVerbose "[FIXUP]FVP re-provision success"
						intertaca_manual -c 23
						if [ $? == 0 ] ; then
							#Update other certificate files
							cp -f ${KEY_SRC_PATH}${FVP_INTERMEDIATE_CERT_NAME} ${KEY_FVP_PATH}${FVP_INTERMEDIATE_CERT_NAME}
							cp -f ${KEY_SRC_PATH}${FVP_CLIENT_KEY_NAME} ${KEY_FVP_PATH}${FVP_CLIENT_KEY_NAME}
							cp -f ${KEY_SRC_PATH}${FVP_CLIENT_CERT_NAME} ${KEY_FVP_PATH}${FVP_CLIENT_CERT_NAME}
							sync

							#correct permission for new copied FVP certficates
							chmod 640 ${KEY_FVP_PATH}*
							chown system:system ${KEY_FVP_PATH}*

							#backup
							/vendor/bin/amzn_drmprov_tool --backup=idme
							FixupVerbose "[FIXUP]check FVP re-provision success"
							touch $KYEU_982_CHECK_FLAG
						fi
					else
						FixupVerbose "[FIXUP]FVP re-provision Failed"
					fi

					rm -f ${KEY_WEBPLATFORM_PATH}${FVP_INTERMEDIATE_KEY_NAME}
				else
					FixupVerbose "[FIXUP]current FVP key deletion Failed"
				fi
			fi
		fi
		

		#Fixup for KYEU-1015 UK device.
		if [ -d ${KEY_WEBPLATFORM_PATH} ]; then
			rm -rf ${KEY_WEBPLATFORM_PATH}
			FixupVerbose "[FIXUP]delete $KEY_WEBPLATFORM_PATH Done"
		else
			FixupVerbose "[FIXUP]Fixup for KYEU-1015 on EVT UK device was already done"
		fi
	else	
		#Fixup for KYEU-1015 EU device.
		if [ -f $KYEU_1015_CHECK_FLAG ]; then	
			FixupVerbose "[FIXUP]Fixup for KYEU-1015 on EVT EU device was already done"
		else
			FixupVerbose "[FIXUP]EU device detected"

			#Fix selinux context first, otherwise delete doesn't work
			ls_ret=`ls -dlZ ${KEY_WEBPLATFORM_PATH}`
			selinux_context=`echo $ls_ret|cut -d " " -F5`
			if [ "$selinux_context" != "u:object_r:tv_certificate_file:s0" ];then
				chcon u:object_r:tv_certificate_file:s0 ${KEY_WEBPLATFORM_PATH}
			fi
			ls_ret=`ls -alZ ${KEY_WEBPLATFORM_PATH}${FVP_INTERMEDIATE_KEY_NAME}`
			selinux_context=`echo $ls_ret|cut -d " " -F5`
			if [ "$selinux_context" != "u:object_r:tv_certificate_file:s0" ];then
				chcon u:object_r:tv_certificate_file:s0 ${KEY_WEBPLATFORM_PATH}${FVP_INTERMEDIATE_KEY_NAME}
			fi
			rm -rf ${KEY_WEBPLATFORM_PATH}

			ls_ret=`ls -dlZ ${KEY_FVP_PATH}`
			selinux_context=`echo $ls_ret|cut -d " " -F5`
			if [ "$selinux_context" != "u:object_r:tv_certificate_file:s0" ];then
				chcon u:object_r:tv_certificate_file:s0 ${KEY_FVP_PATH}
			fi
			fvp_context_num=`ls -alZ ${KEY_FVP_PATH}* | grep -w "u:object_r:tv_certificate_file:s0" | wc -l`
			if [ $fvp_context_num -ne 3 ]; then
				chcon u:object_r:tv_certificate_file:s0 ${KEY_FVP_PATH}*
			fi
			rm -rf ${KEY_FVP_PATH}
			touch $KYEU_1015_CHECK_FLAG
			FixupVerbose "[FIXUP]delete ${KEY_WEBPLATFORM_PATH} and ${KEY_FVP_PATH} Done"
		fi
	fi
fi


