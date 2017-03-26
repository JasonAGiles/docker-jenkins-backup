# Jenkins Backup
This Docker image is designed to take regular backups of a running Jenkins master.
The image works by using a cron job to regularly archive the contents of the Jenkins
home directory and copy the archive files into a backup directory.

## Example Usage
```
docker run --rm --volumes-from <jenkins-container-name> -v $(pwd)/backups:/var/backups -d jagiles/jenkins-backup
```
The above command will start the `jenkins-backup` image with the volumes from the `jenkins` image.
By default, it will take a backup every day at midnight and copy the file to the backups
folder under the current directory the run command is executed from.  It also will
only keep the latest 7 backup files, deleting the oldest one after the backups are run.

## Customization
### Cron Job
By default, the cron job will run every day at midnight.  If you would like to change
how often the cron job is run, pass an environment variable of `CRON_TIME` to the run
command with an alternative cron expression for the time you would like the cron job
to run.

### Max Number of backups
By default, the image will keep the last 7 backup files.  To change this number,
pass an environment variable of `MAX_BACKUPS` with the number of backup files to maintain.

## Example Docker Compose Setup
One way to ensure the `jenkins` and the `jenkins-backup` image are running together would be
to start them using `docker-compose`.  Below is an example docker-compose file to ensure both
images are running together and are sharing the `/var/jenkins_home` data volume.

```yml
version: "3.1"

services:
  jenkins:
    image: jenkins:latest
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - jenkins-home:/var/jenkins_home
  jenkins-backup:
    image: jagiles/jenkins-backup:latest
    volumes:
      - jenkins-home:/var/jenkins_home
      - ./backups:/var/backups

volumes:
  jenkins-home:
```
