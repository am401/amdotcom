#!/bin/sh
##########################################
# Deploy script to AWS EC2 for Jekyll site
##########################################

# Read variables from local file to get hostname/syncdir
export $(cat .env | xargs)

# Function to build the site using docker make file
build_site() {
	echo "***** Building Jekyll site. Standby... *****"
	make build
	echo "***** Build complete. Syncing to ec2... *****"
}	

sync_site() {
	rsync -avP _site/ ${SSHHOST}:${JEKYLLDIR}
}
	

# Check if docker is running and if so, build/sync site
if ( docker stats --no-stream &> /dev/null ); then
	build_site
	sync_site
else
	echo "***** Docker is not running. Launching docker. *****"
	open /Applications/Docker.app
	echo "***** Waiting for docker to launch... *****"
	# Docker can take a bit to launch so continue checking until
	# it's running
	while (! docker stats --no-stream &> /dev/null); do
		echo "Standby..."
		sleep 1
	done
	echo "***** Docker is up and running *****"
	build_site
	sync_site
fi
