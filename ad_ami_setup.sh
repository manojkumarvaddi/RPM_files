#!/bin/bash
userdata=/AD/serverdetails.json
while [ ! -f $userdata ]
do
  sleep 1 
done

sudo rpm -ivh acqueon-desktop-workspace*.rpm

if [ -f /etc/systemd/system/lynx.admin.service ]; then
    V_INSTALL_PATH=$(sudo cat /etc/systemd/system/lynx.admin.service | grep dll | sed "s/^.*dotnet \(.*\)\/lynx.*$/\1/g")
else
    echo "Unable to find Admin Service"
    exit 0
fi
if [ -z $V_INSTALL_PATH ]; then
    echo "Unable to find Install Path"
    exit 0
fi

echo "Configuration File: ${V_INSTALL_PATH}/lynx/desktop/ad-workspace.env"

V_PUBLIC_DN=$(sudo jq -r '.PUBLIC_ELB_DNS' $userdata)
V_PRIVATE_DN=$(sudo jq -r '.PRIVATE_ELB_DNS' $userdata)
V_REDIS_DN=$(sudo jq -r '.Elasticache_Primary_Endpoint' $userdata)

sudo sed -i "s/PUBLIC_HOST=.*/PUBLIC_HOST=$V_PUBLIC_DN/g" $V_INSTALL_PATH/lynx/desktop/ad-workspace.env
sudo sed -i "s/PRIVATE_ELB=.*/PRIVATE_ELB=$V_PRIVATE_DN/g" $V_INSTALL_PATH/lynx/desktop/ad-workspace.env
sudo sed -i "s/REDIS_PRIMARY_HOST=.*/REDIS_PRIMARY_HOST=$V_REDIS_DN/g" $V_INSTALL_PATH/lynx/desktop/ad-workspace.env

sudo $V_INSTALL_PATH/lynx/desktop/setup.sh


# if amazon enabled?
