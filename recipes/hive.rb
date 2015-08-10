#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2015 Álvaro Faúndez
#
# All rights reserved - Do Not Redistribute
#

package 'hadoop-hive' do
  options '--force-yes' if platform?('ubuntu')
end

mysql_service 'hadoop-hive' do
  port '3307'
  version '5.1'
  initial_root_password 'root123'
  action [:create, :start]
end

mysql2_chef_gem 'hadoop-hive' do
  provider Chef::Provider::Mysql2ChefGem::Mysql
  action :install
end

mysql_connection_info = {
  :host => 'localhost',
  :username => 'root',
  :password => 'root123',
  :socket => "/var/run/mysql-hadoop-hive/mysqld.sock"
}

mysql_database 'metastore' do
  connection mysql_connection_info
  action :create
end

execute "mysql -uroot -proot123 --socket /var/run/mysql-hadoop-hive/mysqld.sock metastore  < /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.7.0.mysql.sql"

mysql_database_user 'hiveuser' do
  connection mysql_connection_info
  password 'password'
  action :create
end

mysql_database 'grant hiveuser' do
  connection mysql_connection_info
  sql "GRANT SELECT,INSERT,UPDATE,DELETE ON metastore.* TO 'hiveuser'@'%'"
  action :query
end

mysql_database 'revoke hiveuser' do
  connection mysql_connection_info
  sql "REVOKE ALTER,CREATE ON metastore.* FROM 'hiveuser'@'%'"
  action :query
end

mysql_database 'flush privileges' do
  connection mysql_connection_info
  sql "FLUSH PRIVILEGES"
  action :query
end

remote_file '/tmp/mysql-connector-java-5.1.15.tar.gz' do
  source 'https://dl.dropbox.com/u/8130946/firenxis/mysql-connector-java-5.1.15.tar.gz'
  action :create_if_missing
end

execute 'uncompress mysql-connector-java' do
  cwd '/tmp'
  command 'tar xzf mysql-connector-java-5.1.15.tar.gz; mv mysql-connector-java-5.1.15-bin.jar /usr/lib/hive/lib/'
  creates '/usr/lib/hive/lib/mysql-connector-java-5.1.15-bin.jar'
end

directory node[:hadoop][:hive][:custom_conf] do
  mode 0755
end

hive_config_hash = Mash.new(node[:hadoop][:hive])
log hive_config_hash
%w[ hive-site.xml hive-default.xml hive-log4j.properties
  hive-exec-log4j.properties
].each do |conf_file|
  template "#{node[:hadoop][:hive][:custom_conf]}/#{conf_file}" do
    owner "root"
    mode "0644"
    variables(:hive => hive_config_hash)
    source "#{conf_file}.erb"
  end
end

execute 'update hive-conf alternatives' do
  command "update-alternatives --install /etc/hive/conf hive-conf #{node[:hadoop][:hive][:custom_conf]} 50"
  not_if "update-alternatives --display hive-conf | grep best | awk '{print $5}' | grep #{node[:hadoop][:hive][:custom_conf]}"
end
