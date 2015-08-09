#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2015 Álvaro Faúndez
#
# All rights reserved - Do Not Redistribute
#

if node[:apt][:cloudera][:force_distro] != node[:lsb][:codename]
  Chef::Log.info "Forcing cloudera distro to '#{node[:apt][:cloudera][:force_distro]}' (your machine is '#{node[:lsb][:codename]}')"
end

case node[:platform]
when 'ubuntu'
  apt_repository 'cloudera' do
    uri             'http://archive.cloudera.com/debian'
    distro        = node[:apt][:cloudera][:force_distro] || node[:lsb][:codename]
    distribution    "#{distro}-#{node[:apt][:cloudera][:release_name]}"
    components      ['contrib']
    key             "http://archive.cloudera.com/debian/archive.key"
    action          :add
  end
when 'centos'
  yum_repository 'cloudera-cdh3u5' do
    description 'CDH3 Update 5'
    mirrorlist  'http://archive.cloudera.com/redhat/6/x86_64/cdh/3u5/mirrors'
    gpgkey 'http://archive.cloudera.com/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera'
    action :create
  end
end

['hadoop-0.20-datanode', 'hadoop-0.20-tasktracker'].each do |pack|
  package pack do
    options '--force-yes' if platform?('ubuntu')
  end
end

include_recipe 'cdh3::conf'

service 'hadoop-0.20-jobtracker' do
  action [ :start, :enable ]
end

service 'hadoop-0.20-tasktracker' do
  action [ :start, :enable ]
end

['hadoop-0.20-namenode', 'hadoop-0.20-jobtracker'].each do |pack|
  package pack do
    options '--force-yes' if platform?('ubuntu')
  end
end

execute 'hadoop namenode -format' do
  user 'hdfs'
  group 'hdfs'
  not_if "ls #{node[:hadoop][:tmp_dir]}/hadoop-hdfs/dfs/name"
end

service 'hadoop-0.20-namenode' do
  action [ :start, :enable ]
end

service 'hadoop-0.20-datanode' do
  action [ :start, :enable ]
end
