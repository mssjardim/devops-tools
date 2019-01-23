systemctl stop mongod
rm -rf /data/db
rm -rf /opt/mongodb
rm /etc/systemd/system/mongod.service
