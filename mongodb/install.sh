#!/bin/bash
set -e

LINUX=ubuntu1404
MONGO_VERSION=4.0.5
MONGO_DIR=/opt
MONGO_USER=admin
MONGO_PASSWORD=123456

### DO NOT CHANGE CONFIGURATIONS BELLOW ###

DIRNAME=mongodb-linux-x86_64-$LINUX-$MONGO_VERSION
FILENAME=$DIRNAME.tgz

echo "Download $FILENAME"
curl -OL https://fastdl.mongodb.org/linux/$FILENAME

echo "Extract $FILENAME to $DIRNAME"
tar -zxvf $FILENAME

echo "Copy mongodb to $MONGO_DIR/mongodb"
mv $DIRNAME/bin $MONGO_DIR/mongodb

echo "Copy binaries to /usr/local/bin"
cp $MONGO_DIR/mongodb/* /usr/local/bin/
rm /usr/local/bin/mongod

echo "Remove downloaded file from current directory"
rm -rf $DIRNAME $FILENAME

echo "Create database folder /data/db"
mkdir -p /data/db
chmod -R 777 /data

echo "Create user mongodb"
getent passwd mongodb || useradd mongodb

echo "Start mongod as replicaSet called rs0"
sudo -Hu mongodb $MONGO_DIR/mongodb/mongod --dbpath /data/db --replSet "rs0" &

sleep 10
echo "Initialize replicaSet"
mongo -- <<EOF
rs.initiate();
EOF

sleep 5
mongo -- <<EOF
use admin;
db.createUser({
    user: '$MONGO_USER',
    pwd: '$MONGO_PASSWORD',
    roles: [ 'clusterAdmin', 'userAdminAnyDatabase' ]
});
EOF

echo "Shutdown Mongodb"
$MONGO_DIR/mongodb/mongod --shutdown

sleep 5
echo "Create mongod as a service"
cp mongod.service /etc/systemd/system
sleep 1
systemctl daemon-reload
systemctl enable mongod.service
systemctl start mongod.service

echo "Done!"
