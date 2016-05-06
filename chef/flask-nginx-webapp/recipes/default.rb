#
# Cookbook Name : blog server using python, nginx and flask
#
# Recipe : default
#
#

# Install , enable by default, will start after loading python script with flask
package ['nginx'] do
 action [ :install :enable ]
end

# Install flask
package 'flask' do
 action :install
end

# install python dependencies, requires uwsgi for integrating with nginx

package ['python','python-dev','uwsgi']
 action :install
end

#create required directories for the app

directory ["/etc/uwsgi","/etc/uwsgi/vassals","/var/www/demoapp","/var/log/uwsgi"] do
 owner 'www'
 group 'www'
 mode '0644'
 recursive true
end

# path to python script which uses flask and runs on port 8080

cookbook_file "/var/www/demoapp/hello.py" do
 source "hello.py"
 mode "0644"
end

# start the python/flask script
#
execute 'start_flask' do
 command 'python /var/www/demoapp/hello.py'
end

#remove default nginx conf files

file '/etc/nginx/sites-enabled/default' do
 action :delete
end

#copy our nginx conf file
#
cookbook_file "/var/www/demoapp/demoapp_nginx.conf" do
 source "demoapp_nginx.conf"
 mode "0644"
end

#link it to nginx conf location
#
link "/var/www/demoapp/demoapp_nginx.conf" do
 to "/etc/nginx/conf.d/"
end

#load the uwsgi plugin for python
cookbook_file "/var/www/demoapp/demoapp_uwsgi.ini" do
 source "demoapp_uwsgi.ini"
end

# load uwsgi conf file , so that it can be started as a daemon
cookbook_file "/etc/init/uwsgi.conf" do
 source uwsgi.conf
end

#link it to default path for uwsgi
#
link "/var/www/demoapp/demoapp_uwsgi.ini" do
 to "/etc/uwsgi/vassals"
end

#start uwsgi service
service "uwsgi" do
 action :start
end

#start nginx server
service "nginx" do
 action :start
end



