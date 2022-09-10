   Gitlab Tool'unun upgrade'ine ilişkin bir dökümantasyon.

# NOTES ABOUT GITLAB UPGRADE
## The upgrading plan should has this steps;

1. Create and extract backup on old server.

2. Install Docker and GitLab Container.

3. Import the backup on the new server.

4. Upgrade GitLab to the current version.

“You can only restore a backup to exactly the same version and type (CE / EE) of GitLab on which it was created.”

GitLab itself recommends that the installation is to be carried out using “Omnibus“. Omnibus installs all required programs, such as “PostgreSQL”, “Redis” and “Unicorn”.

## Implementation & Linux shell commands

1. Create and extract backup on the old server:

By default, GitLab stores backups under “/ var / opt / gitlab / backups”. The backup that will be created shortly can be extracted from there.

Navidate to the backup folder
```bash
$ cd /var/opt/gitlab/backups
```

Creating a Gitlab backup
```bash
sudo gitlab-rake gitlab:backup:create
```

Check whether the new backup was created successfully.
(it can be recognized by the time stamp: xxx_YYYY_MM_DD_10.0.2_gitlab_backup_tar9
ls

Extract the backup now

2. Install Docker & GitLab Container

First we install Docker in Debian. It must be ensured that the hardware requirements are met.

```bash
# Docker installation:

sudo apt-get update
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo docker run hello-world
```

Next we install the older GitLab container exactly the same version and type (Here it is: 10.0.2-ee.0):
```bash
# Install Docker containers:

sudo docker run --detach \
  --hostname git.internal.xc \
  --publish 443:443 --publish 80:80 --publish 23:22 \
  --name gitlab \
  --restart always \
  --volume /home/gitlab/config:/etc/gitlab \
  --volume /home/gitlab/logs:/var/log/gitlab \
  --volume /home/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:10.0.2-ee.0
```

```bash
# Docker starts the container directly. 
  In the following we check whether it is also running::

sudo docker ps
```

![Another look to see if the GitLab user interface is accessible:](https://www.inwerken.de/wp-content/uploads/2020/04/Bild_3_Docker_startet.png)

You can connect to Gitlab here for register

3. Import the backup to the new server

First of all we need to send the backup file on the new server. In this case I use SFTP and copy the backup into the home directory. Alternatively, you could use SCP.

```bash
# Move the backup file to the GitLab backup directory:
mv 1585657459_2020_03_31_10.0.2_gitlab_backup.tar /home/gitlab/data/backups/
 
# Optional: For security reasons, it is recommended to stop all important running GitLab services
sudo docker exec -t gitlab gitlab-ctl stop puma
sudo docker exec -t gitlab gitlab-ctl stop sidekiq
sudo docker exec -t gitlab gitlab-ctl stop unicorn
 
# How to restore the backup directory:
sudo docker exec -ti gitlab gitlab-rake gitlab:backup:restore BACKUP=1585657459_2020_03_31_10.0.2 force=yes
 
# Now update GitLab once and restart.
sudo docker exec -t gitlab gitlab-ctl reconfigure
sudo docker exec -t gitlab gitlab-ctl restart
 
# Then the logs should be checked again. 
  We make sure that there are no critical errors
sudo docker logs -f gitlab
```

GitLab takes one to two minutes to restart. If we now check the GitLab web interface, we can see that the backup has successfully imported all the data again.

4. Upgrade GitLab to the current version

Now upgrade GitLab from 13.12 to the current version 15.3.3. Unfortunately, A direct jump from GitLab 13 to 15 is not possible.

### “It is considered safe to jump between patch versions and minor versions within one major version.” ![Source: GitLab,](https://docs.gitlab.com/ee/policy/maintenance.html#version-12-onwards-extra-step-for-major-upgrades (2020))

-	Find where your version sits in the upgrade path below, and upgrade GitLab accordingly, while also consulting the version-specific upgrade instructions (https://docs.gitlab.com/ee/update/#upgrade-paths):

-	8.11.Z -> 8.12.0 -> 8.17.7 -> 9.5.10 -> 10.8.7 -> 11.11.8 -> 12.0.12 -> 12.1.17 -> 12.10.14 -> 13.0.14 -> 13.1.11 -> 13.8.8 -> 13.12.15 -> 14.0.12 -> 14.3.6 -> 14.9.5 -> 14.10.Z -> 15.0.Z -> 15.4.0 -> latest 15.Y.Z

So for our case a step-by-step upgrade is necessary here and the following steps must therefore be repeated for each CONTAINER VERSION:**13.12.15 -> 14.0.12 -> 14.3.6 -> 14.9.5 -> 14.10.Z -> 15.0.Z -> 15.4.0 -> latest 15.Y.Z**

```bash
# Stop container:
sudo docker stop gitlab
 
# Remove Container:
sudo docker rm gitlab
 
# Then extract from DockerHub GitLab  [CONTAINERVERSION] extrahieren:
sudo docker pull gitlab/gitlab-ee:[CONTAINERVERSION]
 
# Now reinitialize the container, but this time with version [CONTAINERVERSION].
sudo docker run --detach \
  --hostname git.internal.xc \
  --publish 443:443 --publish 80:80 --publish 23:22 \
  --name gitlab \
  --restart always \
  --volume /home/gitlab/config:/etc/gitlab \
  --volume /home/gitlab/logs:/var/log/gitlab \
  --volume /home/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:[CONTAINERVERSION]
 
# Check the logs again with:
sudo docker logs -f gitlab
 
# Now we use the web interface to check whether the upgrade was successful. 
http://[Serveradresse]/help
 
# Important: It is advisable to make a backup after each upgrade. 
  For the case of falls.
sudo docker exec -ti gitlab gitlab-rake gitlab:backup:create
```


# Notes

## Create a GitLab upgrade plan
(https://docs.gitlab.com/ee/update/plan_your_upgrade.html)

- General notes:

    * If possible, we recommend you test out the upgrade in a test environment before updating your production instance. Ideally, your test environment should mimic your production environment as closely as possible.

    * If working with Support to create your plan, share details of your architecture, including:

      * How is GitLab installed?
      * What is the operating system of the node? (check OS versions that are no longer supported to confirm that later updates are available).
      * Is it a single-node or a multi-node setup? If multi-node, share any architectural details about each node with us.
      * Are you using GitLab Geo? If so, share any architectural details about each secondary node.
      * What else might be unique or interesting in your setup that might be important for us to understand?
      * Are you running into any known issues with your current version of GitLab?

- For the upgrade plan, start by creating an outline of a plan that best applies to your instance and then upgrade it for any relevant features you’re using.

  * Generate an upgrade plan by reading and understanding the relevant documentation:

    * upgrade based on the installation method:
      * Linux package (Omnibus)
      * Compiled from source
      * Docker
      * Helm Charts
    * Zero-downtime upgrades (if possible and desired)
    * Convert from GitLab Community Edition to Enterprise Edition

  * What version should you upgrade to:
    * Determine what upgrade path to follow.
    * Account for any version-specific update instructions.
    * Account for any version-specific changes.
    * Check the OS compatibility with the target GitLab version.

  * Due to background migrations, plan to pause before any further upgrades. All migrations must finish running before the next upgrade.

  * If available in your starting version, consider turning on maintenance mode during the upgrade.

  * About PostgreSQL:
      * On the top bar, select Menu > Admin, and look for the version of PostgreSQL you are using. If a PostgreSQL upgrade is needed, account for the relevant packaged or non-packaged steps.

# Pre-upgrade and post-upgrade checks

Immediately before and after the upgrade, perform the pre-upgrade and post-upgrade checks to ensure the major components of GitLab are working:

1. Check the general configuration:

```bash
sudo gitlab-rake gitlab:check
```

2. Confirm that encrypted database values can be decrypted:

```bash
sudo gitlab-rake gitlab:doctor:secrets
```

3. In GitLab UI, check that:

* Users can log in.
* The project list is visible.
* Project issues and merge requests are accessible.
* Users can clone repositories from GitLab.
* Users can push commits to GitLab.

4. For GitLab CI/CD, check that:

* Runners pick up jobs.
* Docker images can be pushed and pulled from the registry.

5. If using Geo, run the relevant checks on the primary and each secondary:

* sudo gitlab-rake gitlab:geo:check

6. If using Elasticsearch, verify that searches are successful.

7. If you are using Reply by Email or Service Desk, manually install the latest version of gitlab-mail_room:

## Upgrading GitLab (https://docs.gitlab.com/ee/update/)

## Upgrade based on installation method

Depending on the installation method and your GitLab version, there are multiple official ways to update GitLab:

* Linux packages (Omnibus GitLab) (https://docs.gitlab.com/ee/update/package/index.html)
* Source installations
* Docker installations (https://docs.gitlab.com/ee/install/docker.html)
* Kubernetes (Helm) installations

### Installation using Docker
GitLab provides official Docker images and they are based on the Omnibus package.

### Checking for background migrations before upgrading

Certain releases may require different migrations to be finished before you update to the newer version.

**Batched migrations are a migration type available in GitLab 14.0 and later.** Background migrations and batched migrations are not the same, so you should check that both are complete before updating.

Decrease the time required to complete these migrations by increasing the number of Sidekiq workers that can process jobs in the background_migration queue.

### Upgrading to a new major version

Upgrading the major version requires more attention. Follow the directions carefully as we cannot guarantee that upgrading between major versions is seamless.

**A major upgrade requires the following steps:(https://docs.gitlab.com/ee/update/#upgrading-to-a-new-major-version)**
* Start by identifying a supported upgrade path (https://docs.gitlab.com/ee/update/#upgrade-paths). This is essential for a successful major version upgrade.
* Upgrade to the latest minor version of the preceding major version (**Note: Our minor version is already the latest one**).
* Upgrade to the “dot zero” release of the next major version (X.0.Z).
* Optional. Follow the upgrade path, and proceed with upgrading to newer releases of that major version.

It’s also important to ensure that any background migrations have been fully completed before upgrading to a new major version.(https://docs.gitlab.com/ee/update/#checking-for-background-migrations-before-upgrading)

If your GitLab instance has any runners associated with it, it is very important to upgrade GitLab Runner to match the GitLab minor version that was upgraded to.

### Upgrade paths (https://docs.gitlab.com/ee/update/#upgrade-paths)

Upgrading across multiple GitLab versions in one go is only possible by accepting downtime. The following examples assume downtime is acceptable while upgrading. If you don’t want any downtime, read how to [upgrade with zero downtime.](https://docs.gitlab.com/ee/update/zero_downtime.html)

Find where your version sits in the upgrade path below, and upgrade GitLab accordingly, while also consulting the version-specific upgrade instructions:

**8.11.Z -> 8.12.0 -> 8.17.7 -> 9.5.10 -> 10.8.7 -> 11.11.8 -> 12.0.12 -> 12.1.17 -> 12.10.14 -> 13.0.14 -> 13.1.11 -> 13.8.8 -> 13.12.15 -> 14.0.12 -> 14.3.6 -> 14.9.5 -> 14.10.Z -> 15.0.Z -> 15.4.0 -> latest 15.Y.Z**

When not explicitly specified, upgrade GitLab to the latest available patch release rather than the first patch release, for example 13.8.8 instead of 13.8.0. This includes versions you must stop at on the upgrade path as there may be fixes for issues relating to the upgrade process.

When we search about the minimally necessary steps only for our case:

**13.12.15 -> 14.0.12 -> 14.3.6 -> 14.6.2 -> 14.9.5 -> 14.10.5 -> 15.0.2 -> 15.1.0 -> ... -> 15.3.3**

### Version-specific upgrading instructions

Each month, major, minor, or patch releases of GitLab are published along with a release post. You should read the release posts for all versions you’re passing over (https://about.gitlab.com/releases/categories/releases/?_gl=1*1lahz8x*_ga*MTA3ODU1NTMxOC4xNjYyNTU4MTIx*_ga_ENFH3X7M5Y*MTY2MjU3ODQzMC4zLjEuMTY2MjU4NTU0MC4wLjAuMA..).

- 13.12.0 (Example)

  * See Maintenance mode issue in GitLab 13.9 to 14.4 (https://docs.gitlab.com/ee/update/#maintenance-mode-issue-in-gitlab-139-to-144).

  * Check the GitLab database has no references to legacy storage (https://docs.gitlab.com/ee/administration/raketasks/storage.html#on-legacy-storage). The GitLab 14.0 pre-install check causes the package update to fail if unmigrated data exists:

    - Checking for unmigrated data on legacy storage

    - Legacy storage is no longer supported. Please migrate your data to hashed storage.


## GitLab release and maintenance policy

Gitlab release policy is:

* Backporting bug fixes for only the current stable release at any given time.
* Backporting security fixes to the previous two monthly releases in addition to the current stable release.

## Upgrade recommendations

We encourage everyone to run the latest stable release (15.3.3)


# Upgrade GitLab by using the GitLab package (Omnibus GitLab)
(https://docs.gitlab.com/ee/update/package/index.html)

## Prerequisites (https://docs.gitlab.com/ee/update/package/index.html#prerequisites)

  * Decide when to upgrade by viewing the supported upgrade paths. You can’t directly skip major versions (for example, go from 10.3 to 12.7 in one step).

  * Ensure that any background migrations are fully completed (https://docs.gitlab.com/ee/update/index.html#checking-for-background-migrations-before-upgrading). We recommend performing upgrades between major and minor releases no more than once per week, to allow time for background migrations to finish.

  * Gitaly servers must be upgraded to the newer version prior to upgrading the application server. This prevents the gRPC client on the application server from sending RPCs that the old Gitaly version does not support.

## Downtime

  * For single node installations, GitLab is not available to users while an upgrade is in progress. The user’s web browser shows a Deploy in progress message or a 502 error.

  * For multi-node installations, see how to perform zero downtime upgrades.

  * Upgrades to multi-node installations can also be performed with downtime.

## Back up before upgrading

The GitLab database is backed up before installing a newer GitLab version. You may skip this automatic database backup by creating an empty file at /etc/gitlab/skip-auto-backup:

```bash
sudo touch /etc/gitlab/skip-auto-backup
```

Nevertheless, it is highly recommended to maintain a full up-to-date backup on your own.

## Upgrade using the official repositories 
(https://docs.gitlab.com/ee/update/package/index.html#upgrade-using-the-official-repositories)

All GitLab packages are posted to the GitLab package server. Five repositories are maintained:

* gitlab/gitlab-ee: The full GitLab package that contains all the Community Edition features plus the Enterprise Edition ones.
* gitlab/gitlab-ce: A stripped down package that contains only the Community Edition features.
* gitlab/unstable: Release candidates and other unstable versions.
* gitlab/nightly-builds: Nightly builds.
* gitlab/raspberry-pi2: Official Community Edition releases built for Raspberry Pi packages.

If you have installed GitLab Community Edition or Enterprise Edition, then the official GitLab repository should have already been set up for you.

## Upgrade to a specific version using the official repositories

To specify the intended GitLab version number in your package manager’s install or upgrade command:

- Identify the version number of the installed package:

```bash
# Ubuntu/Debian

sudo apt-cache madison gitlab-ee
```

- Install the specific gitlab-ee package by using one of the following commands and replacing <version> with the next supported version you would like to install (make sure to review the upgrade path to confirm the version you’re installing is part of a supported path):

```bash
# Ubuntu/Debian

sudo apt install gitlab-ee=<version>
```


# Upgrade GitLab by using Docker images
(https://docs.gitlab.com/ee/install/docker.html)

The GitLab Docker images are monolithic images of GitLab running all the necessary services in a single container. Find the GitLab official Docker image at: (https://hub.docker.com/r/gitlab/gitlab-ee/)

## Prerequisites

Just docker installation is required.

## Set up the volumes location

Before setting everything else, configure a new environment variable $GITLAB_HOME pointing to the directory where the configuration, logs, and data files will reside. Ensure that the directory exists and appropriate permission have been granted.

```bash
# For Linux users, set the path to /srv/gitlab:

export GITLAB_HOME=/srv/gitlab
```

The GitLab container uses host mounted volumes to store persistent data:

Local location        Container location	    Usage
$GITLAB_HOME/data	    /var/opt/gitlab	        For storing application data.
$GITLAB_HOME/logs	    /var/log/gitlab	        For storing logs.
$GITLAB_HOME/config	  /etc/gitlab	For         storing the GitLab configuration files.

## Installation

The GitLab Docker images can be run in multiple ways (https://docs.gitlab.com/ee/install/docker.html#installation):

* Using Docker Engine
* Using Docker Compose
* Using Docker swarm mode

## Install GitLab using Docker Engine

- You can fine tune these directories to meet your requirements. Once you’ve set up the GITLAB_HOME variable, you can run the image:

```bash
sudo docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ee:latest
```

- The initialization process may take a long time. You can track this process with:

```bash
sudo docker logs -f gitlab
```

- Visit the GitLab URL, and log in with username root and the password from the following command:

```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```