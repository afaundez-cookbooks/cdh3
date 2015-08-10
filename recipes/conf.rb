package 'hadoop-0.20-conf-pseudo' do
  options '--force-yes' if ['ubuntu'].include? node[:platform]
end

directory node[:hadoop][:custom_conf] do
  mode 0755
end

hadoop_config_hash = Mash.new({
  :aws              => (node[:aws] && node[:aws].to_hash),
  :extra_classpaths => node[:hadoop][:extra_classpaths].map{|nm, classpath| classpath }.flatten,
}).merge(node[:hadoop])

%w[ core-site.xml     hdfs-site.xml     mapred-site.xml
    hadoop-env.sh     fairscheduler.xml hadoop-metrics.properties
].each do |conf_file|
  template "#{node[:hadoop][:custom_conf]}/#{conf_file}" do
    owner "root"
    mode "0644"
    variables(:hadoop => hadoop_config_hash)
    source "#{conf_file}.erb"
  end
end

execute 'update hadoop-conf alternatives' do
  command "update-alternatives --install /etc/hadoop-0.20/conf hadoop-0.20-conf #{node[:hadoop][:custom_conf]} 50"
  not_if "update-alternatives --display hadoop-0.20-conf | grep best | awk '{print $5}' | grep #{node[:hadoop][:custom_conf]}"
end
