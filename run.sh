#!/bin/bash

echo "----- CREATING BACKUP SCRIPT -----"

cat << EOF > /backup.sh
#!/bin/bash

cd /var/backups

FILENAME="${BACKUP_FILE_PREFIX}-\$(date +%Y-%m-%d-%H-%M-%S).tgz"
BACKUP_CMD="tar -czvf \${FILENAME} /var/jenkins_home"
MAX_BACKUPS=${MAX_BACKUPS}

echo "----- BACKUP STARTED: \${FILENAME} -----"
\${BACKUP_CMD}
echo "----- BACKUP COMPLETE -----"

if [ -n "\${MAX_BACKUPS}" ]; then
  while [ \$(ls -N1 | wc -l) -gt \${MAX_BACKUPS} ];
  do
    FILE_TO_DELETE=\$(ls -N1 | sort | head -n 1)
    echo "----- REMOVING BACKUP FILE: \${FILE_TO_DELETE} -----"
    rm -f \${FILE_TO_DELETE}
  done
fi
EOF
chmod +x /backup.sh

touch /var/backup.log

echo "${CRON_TIME} /backup.sh >> /var/backup.log 2>&1" > /crontab.conf
crontab /crontab.conf
echo "----- STARTING CRON JOB -----"
cron
exec tail -f /var/backup.log
