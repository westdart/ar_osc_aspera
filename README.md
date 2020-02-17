# ar_osc_aspera
Ansible Role for OpenShift Config targeting the Aspera File transfer
application

## Requirements
The following are RPM requirements for the deployment of Aspera.
These should be either available through subscription-manager or direct
via a web site defined by the variable 'ar_osc_aspera_package_base_url'

### Aspera RPMs
#### Server:
```
ibm-aspera-hsts-3.9.1.168302-linux-6411.rpm
```
#### Endpoint:
```
ibm-aspera-hste-3.9.1.168302-linux-64.rpm
```

#### Aspear RPM dependencies
```
tcp_wrappers-libs-7.6-77.el7.x86_64.rpm
fipscheck-lib-1.4.1-6.el7.x86_64.rpm
fipscheck-1.4.1-6.el7.x86_64.rpm
openssh-7.4p1-21.el7.x86_64.rpm
openssh-server-7.4p1-21.el7.x86_64.rpm
groff-base-1.22.2-8.el7.x86_64.rpm
perl-5.16.3-294.el7_6.x86_64.rpm
perl-Carp-1.26-244.el7.noarch.rpm
perl-Data-Dumper-2.145-3.el7.x86_64.rpm
perl-Encode-2.51-7.el7.x86_64.rpm
perl-Exporter-5.68-3.el7.noarch.rpm
perl-File-Path-2.09-2.el7.noarch.rpm
perl-File-Temp-0.23.01-3.el7.noarch.rpm
perl-Filter-1.49-3.el7.x86_64.rpm
perl-Getopt-Long-2.40-3.el7.noarch.rpm
perl-HTTP-Tiny-0.033-3.el7.noarch.rpm
perl-PathTools-3.40-5.el7.x86_64.rpm
perl-Pod-Escapes-1.04-294.el7_6.noarch.rpm
perl-Pod-Perldoc-3.20-4.el7.noarch.rpm
perl-Pod-Simple-3.28-4.el7.noarch.rpm
perl-Pod-Usage-1.63-3.el7.noarch.rpm
perl-Scalar-List-Utils-1.27-248.el7.x86_64.rpm
perl-Socket-2.010-4.el7.x86_64.rpm
perl-Storable-2.45-3.el7.x86_64.rpm
perl-Text-ParseWords-3.29-4.el7.noarch.rpm
perl-Time-HiRes-1.9725-3.el7.x86_64.rpm
perl-Time-Local-1.2300-2.el7.noarch.rpm
perl-constant-1.27-2.el7.noarch.rpm
perl-libs-5.16.3-294.el7_6.x86_64.rpm
perl-macros-5.16.3-294.el7_6.x86_64.rpm
perl-parent-0.225-244.el7.noarch.rpm
perl-podlators-2.5.1-3.el7.noarch.rpm
perl-threads-1.87-4.el7.x86_64.rpm
perl-threads-shared-1.43-6.el7.x86_64.rpm
dumb-init-1.2.0-1.20170802gitd283f8a.el6.x86_64.rpm
libpcap-1.5.3-11.el7.x86_64.rpm
nmap-ncat-6.40-19.el7.x86_64.rpm"
```


## Role Variables
The following details:
- the parameters that should be passed to the role (aka vars)
- the defaults that are held
- the secrets that should generally be sourced from an ansible vault.

### Parameters:
| Variable                                | Description                                                                         | Default                   |
| --------                                | -----------                                                                         | -------                   |
| ar_osc_aspera_instance                  | Object defining the Aspera instance (see below)                                     | None                      |
| ar_osc_aspera_config_dest               | Path to where generated config files are placed                                     | /tmp                      |
| ar_osc_aspera_docker_registry           | The docker registry to push built images to                                         | None                      |
| ar_osc_aspera_docker_registry_dest_path | The path under the registry where images are pushed (typically a k8s namespace)     | 'openshift'               |
| ar_osc_aspera_package_base_url          | Base URL to where the RPM files can be found (if not using a subscribed base image) | None                      |
| ar_osc_aspera_license_file              | Path to the Aspera license file for the instance                                    | 'aspera_license_file' var |

The 'ar_osc_aspera_instance' variable is an object that contains the details on each instance required.

The structure is:
```
  {
    name:                  "<the name>",
    aspera_image:          "<the image tag to use>",
    aspera_license_file:   "<path to the Aspera license file>",
    aspera_ssh_node_port:  <the TCP port used by the NodePort Service for SSH>,
    aspera_fasp_node_port: <the UDP port used by the NodePort Service for FASP>
  }
```

### Secrets:
| Variable                       | Description                                                                                |
| --------                       | -----------                                                                                |
| aspera_secrets.aspera_password | The password for the Aspera unix user (ar_osc_aspera_username) within the docker container |
| aspera_secrets.aspera_key      | The ssh key for the Aspera unix user (ar_osc_aspera_username) within the docker container  |
 

### Defaults
| Variable                             | Description                                                                 | Default                                                  |
| --------                             | -----------                                                                 | -------                                                  |
| ar_osc_aspera_ns                     | Openshift Namespace / Project                                               | fn: app_namespace                                        |
| ar_osc_aspera_name                   | Application name                                                            | ar_osc_aspera_instance.name                              |
| ar_osc_aspera_launch_script          | The script executed to start Aspera and related processes                   | role_path + '/files/launch.sh'                           |
| ar_osc_aspera_k8s_template           | The k8s template to use                                                     | 'aspera-app-1.yml'                                       |
| ar_osc_aspera_username               | The Aspera username                                                         | 'aspera'                                                 |
| ar_osc_aspera_image_rhel_version     | The version of rhel base image to use (referenced only)                     | '1.0'                                                    |
| ar_osc_aspera_image_base_version     | The version of the Aspera base RHEL image (built and referenced)            | '1.0'                                                    |
| ar_osc_aspera_image_hste_version     | The version of the Aspera HSTE image (built and referenced)                 | '1.0'                                                    |
| ar_osc_aspera_image_hsts_version     | The version of the Aspera HSTS image (built and referenced)                 | '1.0'                                                    |
| ar_osc_aspera_sshd_internal_port     | The SSHD internal port the Aspera Pod listens on                            | '33001'                                                  |
| ar_osc_aspera_server_package         | The Aspera Server package to use                                            | ar_osc_aspera_package_base_url + '/dummy-1-0.noarch.rpm' |
| ar_osc_aspera_endpoint_package       | The Aspera Endpoint package to use                                          | ar_osc_aspera_package_base_url + '/dummy-1-0.noarch.rpm' |
| ar_osc_aspera_have_rhel_subscription | Boolean marking if th base image is subscribed to RedHat satellite channels | false                                                    |
| ar_osc_aspera_package_dependencies   | Direct Aspera package dependencies                                          | (see above RPM requirements)                             |
| ar_osc_aspera_rhel_base_image_name   | The image name given to the RHEL 7 image + dependent packages               | 'aspera-rhel7-base'                                      |
| ar_osc_aspera_package_list           | The complete list of package dependencies                                   | (see RPM requirements above)                             |


## Dependencies

- openshift-applier


## Example Playbook

To create Docker images:
```
- name: Build Aspera Docker images
  hosts: localhost
  tasks:
    - name: Build and Push Aspera images
      include_role:
        name: ar_osc_aspera
        tasks_from: docker
      vars:
        ar_osc_aspera_config_dest: "/tmp/docker"
        ar_osc_aspera_docker_registry: "docker-registry-default.my-openshift.local"
        ar_osc_aspera_package_base_url: "http://localhost:8081/artifactory/dump"
          
```

To create Aspera Config:
```
- name: Build Create Aspera Openshift Config
  hosts: localhost
  vars:
    ar_osc_aspera_instance: {
      name: "my-aspera-instance"
      aspera_image: "aspera-hsts:latest",
      aspera_license_file: "/tmp/aspera-license-server",
      aspera_node_port: 30022
    }
    
  tasks:
    - name: "Build Aspera Config"
      include_role:
        name: ar_osc_aspera
      vars:
        ar_osc_aspera_config_dest:  "/tmp/templates/{{ ar_osc_aspera_instance.name }}"
        ar_osc_aspera_k8s_template: "aspera-app-1.yml"          
```

## Docker Instructions


To build the docker images the rhel7 base image registry must be 
available on the local machine and the operating user must also be able
to execute docker commands as their own user.

To setup docker to do this see the docker documentation. For the version
under test the following has to be undertaken:

1. The docker config file is changed to reference the 'dockerroot' unix
group (note the name of this group changes to 'docker' in later 
versions).
2. Add the user to the 'dockerroot' unix group

On completions, the user should be able to execute docker commands 
without the use of 'sudo'.

## Running multiple Aspera Instances in a Cluster

The design is to run Aspera Nodes across different clusters, however
it can be set up to run multiple instances on a single cluster in 
different namespaces (projects) however, for this to work, the networks
of the projects need to be joined and the cluster ips used instead of
the routes. i.e. to allow traffic to flow from one project to another:
```
$ oc adm pod-network join-projects --to=project1 project2
$ oc adm pod-network join-projects --to=project2 project1
```
This is only required if the network plugin is set to multi-tenant,
if using subnet, all projects can see all other projects, if using 
network-policy, specific policies will need to be setup.

## License

BSD

## Author Information

dstewart@redhat.com
