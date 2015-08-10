#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2015 Álvaro Faúndez
#
# All rights reserved - Do Not Redistribute
#

['hadoop-0.20-datanode', 'hadoop-0.20-tasktracker', 'hadoop-0.20-namenode',
  'hadoop-0.20-jobtracker'
].each do |pack|
  package pack do
    options '--force-yes' if platform?('ubuntu')
  end
end

directory '/var/lib/hadoop-0.20' do
  recursive true
end
directory '/var/lib/hadoop-0.20/dfs' do
  recursive true
  owner 'hdfs'
  group 'hdfs'
end

execute 'hadoop namenode -format' do
  user 'hdfs'
  group 'hdfs'
  not_if "ls /var/lib/hadoop-0.20/dfs/name/current"
end

service 'hadoop-0.20-datanode' do
  action [ :start, :enable ]
end

service 'hadoop-0.20-tasktracker' do
  action [ :start, :enable ]
end

service 'hadoop-0.20-namenode' do
  action [ :start, :enable ]
end

service 'hadoop-0.20-jobtracker' do
  action [ :start, :enable ]
end
