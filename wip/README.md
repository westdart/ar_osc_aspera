# aspera-docker
This WIP is to bring the building of Docker images into Openshift 
(currently done by the Ansible docker_image module.

# Openshift
To get initial build workginin openshift I had to create a 
registry.redhat.io token to enable Openshift to install the image that
enables the build of a docker image: registry.redhat.io/openshift3/ose-docker-builder

Eventually got it to work after doing several things:
- Download the token for registry.redhat.io as a kubernetes template
  - goto : https://catalog.redhat.com/software/containers/explore/
  - Click 'Service Accounts' (top right)
  - Create New Service Account if required and follow instructions
  - Click on the account name created
  - Click 'Openshift' tab
  - Click Download link to download the template (note the name in the metadata of the secret contains random n umber prepended)
- Upload the template and link the secret
  - execute: oc create -f <name of file> --namespace=openshift
  - execute: oc secrets link default <secret name from metadata in file> --for=pull
- Adjacent to this tried getting the image direct:
  - ssh onto the master server
  - Using the credentials from the above service account:
  - execute: docker login -u='<username i.e. random|name>' -p=<token> registry.redhat.io
  - execute: docker pull registry.redhat.io/openshift3/ose-docker-builder:v3.11.141
  - executed: docker push registry.redhat.io/openshift3/ose-docker-builder:v3.11.141
    got: 'already exists' on each layer and 'received unexpected HTTP status: 501 Not Implemented'
    
At this point I noticed it working, most likely due to the 'oc' commands.


virt-install --name guest1-rhel7 \
--description 'RedHat Linux 7 VM' \
--ram 2048 \
--vcpus 2 \
--disk path=/var/lib/libvirt/images/rhel7-guest.img,size=20 \
--os-type linux \
--os-variant rhel7 \
--network bridge=virbr0 \
--graphics vnc,listen=127.0.0.1,port=5901 \
--cdrom /var/lib/libvirt/images/rhel-server-7.7-x86_64-dvd.iso \
--noautoconsole