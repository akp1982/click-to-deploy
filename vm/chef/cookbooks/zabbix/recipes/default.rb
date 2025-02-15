# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'c2d-config::default'
include_recipe 'apache2::default'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

# install zabbix package
apt_repository 'zabbix' do
  uri node['zabbix']['repo']['uri']
  components node['zabbix']['repo']['components']
  distribution node['zabbix']['repo']['distribution']
  key node['zabbix']['repo']['keyserver']
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install packages' do
  package_name node['zabbix']['packages']
  action :install
end

# configure zabbix
bash 'configure zabbix' do
  user 'root'
  cwd '/tmp'
  code <<-EOH

  sed -i 's/# php_value date.timezone/php_value date.timezone/' /etc/apache2/conf-enabled/zabbix.conf
  sed -i '1 i\
RedirectMatch ^/$ /zabbix/
' /etc/apache2/conf-enabled/zabbix.conf

  a2enmod cgi ssl
  a2dissite 000-default
  a2ensite default-ssl

  su - postgres -c 'createuser zabbix'
  su - postgres -c 'createdb -O zabbix zabbix'

  zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix

  ### for PostgreSQL -- uses socket (localhost uses tcp)
  sed -i '/^# DBHost=localhost/ a \
\
DBHost=' /etc/zabbix/zabbix_server.conf

  sed -i 's/# ListenIP=127.0.0.1/ListenIP=127.0.0.1/' /etc/zabbix/zabbix_server.conf

EOH
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'etc-zabbix-web-zabbix-conf-php.erb'
  cookbook 'zabbix'
  owner 'root'
  group 'root'
  mode '0644'
end

service 'apache2' do
  action [ :enable, :restart ]
end

service 'zabbix-server' do
  action [ :enable, :stop ]
end

service 'zabbix-proxy' do
  action [ :enable, :stop ]
end

c2d_startup_script 'zabbix' do
  source 'opt-c2d-scripts-zabbix.erb'
  action :template
end
