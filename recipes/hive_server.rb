#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2015 Álvaro Faúndez
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'cdh3::hive'

package 'hadoop-hive-server' do
  options '--force-yes' if platform?('ubuntu')
end

service 'hadoop-hive-server' do
  action [ :start, :enable ]
end
# TODO: start and enable hive server is not working
