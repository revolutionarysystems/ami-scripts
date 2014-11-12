AMI Scripts
===========

The onstartup.sh script will set the hostname and then trigger a Puppet Agent run, before registering the instance with Route 53.

The onshutdown.sh script will remove this entry from Route 53.

To use these scripts deploy them to an EC2 instance and set the onstartup.sh script to be invoked on startup and the onshutdown.sh script to be invoked on shutdown.

These scripts need to be place in the appropriate startup directories with the desired run level and may look something like this.

```sh
cd /path/to/scripts
./onstartup.sh >> startup.log
```

```sh
cd /path/to/scripts
./onshutdown.sh >> shutdown.log
```

These scripts require that you have an EC2 instance with the Puppet Agent and AWS CLI installed.

One you have created the AMI you can launch new instances using a user data string in the following format

```sh
alias|puppetmaster|zoneid|domain|iptype
```

* alias - The alias used to retrieve the config from Puppet
* puppetmaster - The IP address of the Puppet Master
* zoneid - The ID of the Route 53 Hosted Zone
* domain - The Route 53 domain
* iptype - The type of IP address you want to register with Route 53. Can be "private" or "public"

The last 3 parameters can be left off if you do not with to register the instance with Route 53.