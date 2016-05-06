#aws_integration

Description:
------------
Contains script which can be used to load ec2 instance using Perl AWS (Paws) api. 
"aws-sdk-paws.pl" creates a single ec2 instance and writes back the output in json format. This IP address can be used to access an application server which runs on nginx, using flask on python to produce a simple "Hello world" app.

Usage:
------
Run "aws-sdk-paws.pl" from a host where AWS authentication credentials are stored. The script requires "Paws" module which can be installed through CPAN. Refer below URL for more details regarding Paws
http://search.cpan.org/~jlmartin/Paws-0.07/lib/Paws.pm

 Authentication:
 AWS authentication is completed using below methods
 1. Store the access and secret key in env variables - AWS_ACCESS_KEY and AWS_SECRET_KEY
 2. Store the credentials in ~/.aws/credentials file

After successfull creation of the instacne the script will save the instance ip address and instance id in /tmp/ec2_ip.json. This can be used for connecting to web app. The web app consists of an app which displays "Hello world" using flask and python running on nginx server.

The script also includes secrity group policy for the ec2 instance which allows traffic to port 80,8080 and 443. The flask webapp will be running on port 8080 and can be accessed using the ec2 ip address.


Implementation with Chef:
-------------------------
chef directory contains a package named "flask-nginx-webapp" which takes care of installing below related packages for the webapp. 
1. nginx
2. python,python-dev
3. flask
4. uwsgi

The recipe includes section for creating default directories required for the webapp. It configures the nginx server running python/flask based webapp. 
The cookbook also includes roles for the webapp and environment for prod and qe setup. Follow the steps below to use the cookbook from the admin host

1. Install chef server ( can be included in either a seperate host or from the same admin host )
2. Setup knife.rb and point to the chef server with the cookbook path to be uploaded to server
3. Setup nodes , refer to chef/nodes directory for nodes
4. Load the nodes for prod and testing as below. Use the ec2 instance elasctic ip address for loading prod ec2 instance running the app
$ knife upload nodes
5. List the nodes as below
$ knife list nodes
6. Load the role for webapp server 
$ knife role from file flask-nginx.json
7. Load environment for prod and qe
$ knife environment from file prod.json
$ knife environment from file qe.json  
8. Generate the cookbook flask-nginx-webapp as below
$ knife cookbook create flask-nginx-webapp --cookbook-path ./chef
9. Upload the cookbook to chef server
$ knife cookbook upload flask-nginx-webapp

10. Bootstrap the remote ec2 instance as chef client. Get the ip address of ec2 instance from /tmp/ec2_ip.json
$ knife bootstrap <ec2-ipaddress> -x username -p --sudo
11. Add the ec2 client to flask-nginx role
$ knife node run_list set <ec2-ipaddress> "role[flask-nginx]"
12. List the client as below 
$ knife client show <ec2-ipaddress>
13. Run chef client on remote ec2 instance
$ knife ssh "role:flask-nginx" "sudo chef-client" -x user -a <ec2-ipaddress>





 

