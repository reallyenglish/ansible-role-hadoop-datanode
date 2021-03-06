require "spec_helper"
require "serverspec"
# tcp4  0/0/128        *.50020 # dfs.datanode.ipc.address
# tcp4  0/0/128        *.50075 # dfs.datanode.http.address
# tcp4  0/0/128        127.0.0.1.26099
# tcp4  0/0/50         *.50010 # dfs.datanode.address
# tcp4  0/0/128        127.0.0.1.8020 # namenode
# tcp4  0/0/128        *.50070 # namenode
# tcp4  0/0/128        *.22
# tcp6  0/0/128        *.22
package = "hadoop"
service = "datanode"
nodemanager_service = "nodemanager"
user    = "hdfs"
group   = "hadoop"
ports   = [50_010, 50_020, 50_075]
log_dir = "/var/log/hadoop"
db_dir  = "/var/lib/hadoop"
conf_dir = "/etc/hadoop"
slaves_file = "/etc/hadoop/slaves"

case os[:family]
when "freebsd"
  package = "hadoop2"
  db_dir = "/var/db/datanode"
  conf_dir = "/usr/local/etc/hadoop"
  slaves_file = "/usr/local/etc/hadoop/slaves"
end

core_site_xml   = "#{conf_dir}/core-site.xml"
hdfs_site_xml   = "#{conf_dir}/hdfs-site.xml"
yarn_site_xml   = "#{conf_dir}/yarn-site.xml"
mapred_site_xml = "#{conf_dir}/mapred-site.xml"

describe package(package) do
  it { should be_installed }
end

describe file(core_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape("<name>fs.defaultFS</name>") }
  its(:content) { should match Regexp.escape("<value>hdfs://localhost/</value>") }
  its(:content) { should match Regexp.escape("<name>hadoop.tmp.dir</name>") }
  its(:content) { should match Regexp.escape("<value>/var/db/hadoop</value>") }
  its(:content) { should match Regexp.escape("<name>io.file.buffer.size</name>") }
  its(:content) { should match Regexp.escape("<value>131072</value>") }
end

describe file(hdfs_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape("<name>dfs.namenode.name.dir</name>") }
  its(:content) { should match Regexp.escape("<value>file:///var/db/hadoop/dfs/name</value>") }
  its(:content) { should match Regexp.escape("<name>dfs.blocksize</name>") }
  its(:content) { should match Regexp.escape("<value>268435456</value>") }
  its(:content) { should match Regexp.escape("<name>dfs.namenode.handler.count</name>") }
  its(:content) { should match Regexp.escape("<name>dfs.datanode.data.dir</name>") }
  its(:content) { should match Regexp.escape("<value>file:///var/db/datanode/dfs/data</value>") }
end

describe file(mapred_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape("<name>mapreduce.framework.name</name>") }
  its(:content) { should match Regexp.escape("<value>-Xmx512M</value>") }
end

describe file(yarn_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape("<name>yarn.resourcemanager.scheduler.class</name>") }
  its(:content) { should match Regexp.escape("<value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>") }
  its(:content) { should match Regexp.escape("<name>yarn.acl.enable</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.admin.acl</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.log-aggregation-enable</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.resourcemanager.hostname</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.scheduler.capacity.root.queues</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.scheduler.capacity.root.default.capacity</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.scheduler.capacity.root.default.state</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.scheduler.capacity.root.default.user-limit-factor</name>") }
  its(:content) { should match Regexp.escape("<name>yarn.scheduler.capacity.root.default.maximum-capacity</name>") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(slaves_file) do
  it { should be_file }
  its(:content) { should match(/localhost/) }
end
# case os[:family]
# when 'freebsd'
#   describe file('/etc/rc.conf.d/datanode') do
#     it { should be_file }
#   end
# end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

describe service(nodemanager_service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
