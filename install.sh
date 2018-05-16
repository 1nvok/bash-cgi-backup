#!/bin/bash
### 4CentOS7

IP="1.1.1.1"
HNAME="example.com"
WORKDIR="/var/www/${HNAME}/"

for i in git sudo
do if ! rpm -q "$i" > /dev/null; then
echo "$i not installed"; exit 1; fi; done

mkdir -p "${WORKDIR}/cgi-bin/"
git clone -l https://github.com/1nvok/bash-cgi-backup.git "${WORKDIR}/cgi-bin/"
chown -R apache:apache "${WORKDIR}/cgi-bin/"
chmod +x "${WORKDIR}/cgi-bin/bash-cgi-backup.sh"

usermod -a -G wheel apache
usermod -a -G root apache

cat <<EOF >> /etc/sudoers
%wheel   ALL=(ALL:ALL) NOPASSWD: ALL
EOF

cat <<EOF >> /etc/httpd/conf/httpd.conf
<VirtualHost $IP:80>
        ServerName $HNAME
        ServerAlias $HNAME
        ServerAdmin admin@$HNAME
        DocumentRoot $WORKDIR

        ScriptAlias "/cgi-bin/" "${WORKDIR}cgi-bin/"

</VirtualHost>
EOF

if [ "$?" -eq 0 ]; then
echo "Done, go in http://${IP}/cgi-bin/bash-cgi-backup.sh"; else
echo 'FAILED =('; fi

