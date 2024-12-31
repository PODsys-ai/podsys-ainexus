#!/bin/bash
cd $(dirname $0)

G_SERVER_IP="$1"
G_STORAGE="$2"

wget -q http://${G_SERVER_IP}:8800/workspace/iplist.txt || true
SN=`dmidecode -t 1|grep Serial|awk -F : '{print $2}'|awk -F ' ' '{print $1}'`
curl -X POST -d "serial=$SN" http://"${G_SERVER_IP}":5000/receive_serial_s
HOSTNAME=`grep $SN ./iplist.txt|awk  '{print $2}'`

if [ $# -ge 3 ] && [ "$3" = "debug" ]; then
    lsblk_output=$(lsblk)
    ipa_output=$(ip a)
    curl -X POST -d "serial=$SN&lsblk=$lsblk_output&ipa=$ipa_output" http://"$G_SERVER_IP":5000/debug
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config.d/50-cloud-init.conf
    systemctl restart ssh
fi

# preseed network config
network_interface=$(ip route | grep default | awk 'NR==1 {print $5}')
if [ -n "$HOSTNAME" ];then
        sed -i "s/hostname:\ nexus/hostname:\ $HOSTNAME/g"  /autoinstall.yaml
else
        sed -i "s/hostname:\ nexus/hostname:\ node${SN}/g"  /autoinstall.yaml
fi
sed -i "s/nic/$network_interface/g"  /autoinstall.yaml

sata_list=$(lsblk -o NAME,TRAN | grep "sata" | awk '{print $1}')
nvme_list=$(lsblk -o NAME,TRAN | grep "nvme" | awk '{print $1}')
sas_list=$(lsblk -o NAME,TRAN | grep "sas" | awk '{print $1}')

if [ -z "$sata_list" ] && [ -z "$nvme_list" ] && [ -z "$sas_list" ]; then
    curl -X POST -d "serial=$SN&diskstate=none" "http://${G_SERVER_IP}:5000/diskstate"
else
    if lsblk | grep -q "$G_STORAGE" ; then
         curl -X POST -d "serial=$SN&diskstate=ok" "http://${G_SERVER_IP}:5000/diskstate"
    else
         curl -X POST -d "serial=$SN&diskstate=nomatch" "http://${G_SERVER_IP}:5000/diskstate"
    fi
fi