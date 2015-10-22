#
# Cookbook Name:: hadoop
# Recipe:: default
#
# Copyright (C) 2015 Álvaro Faúndez
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'java'

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

include_recipe 'cdh3::conf'

include_recipe 'cdh3::cluster'
