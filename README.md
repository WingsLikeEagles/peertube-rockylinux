# peertube-rockylinux
Terraform plan to install Peertube on a Rocky Linux 8.4 instance in AWS Cloud  

You'll obviously need an AWS account for this.  This should work in the Free Tier.  
You also need to create a Key for connecting to the instance using ssh named "peertube" or change the name in the TF file.  
  
So far this just installs the pre-reqs found on https://docs.joinpeertube.org/dependencies?id=centos-8  (which is no small achievement since it's not written for Rocky, but CentOS)
- Install NodeJS 12  
- Install Yarn  
- Install ffmpeg  

More to come...
