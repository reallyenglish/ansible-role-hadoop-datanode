require 'spec_helper'
require 'serverspec'
# tcp4  0/0/128        *.50020 # dfs.datanode.ipc.address
# tcp4  0/0/128        *.50075 # dfs.datanode.http.address
# tcp4  0/0/128        127.0.0.1.26099        
# tcp4  0/0/50         *.50010 # dfs.datanode.address
# tcp4  0/0/128        127.0.0.1.8020 # namenode
# tcp4  0/0/128        *.50070 # namenode
# tcp4  0/0/128        *.22                   
# tcp6  0/0/128        *.22     
package = 'hadoop'
service = 'datanode'
user    = 'hdfs'
group   = 'hadoop'
ports   = [ 50010, 50020, 50075 ]
log_dir = '/var/log/hadoop'
db_dir  = '/var/lib/hadoop'

core_site_xml = '/etc/hadoop/core-site.xml'
hdfs_site_xml = '/etc/hadoop/hdfs-site.xml'
mapred_site_xml = '/etc/hadoop/mapred-site.xml'

case os[:family]
when 'freebsd'
  package = 'hadoop2'
  db_dir = '/var/db/hadoop'
  core_site_xml = '/usr/local/etc/hadoop/core-site.xml'
  hdfs_site_xml = '/usr/local/etc/hadoop/hdfs-site.xml'
  mapred_site_xml = '/usr/local/etc/hadoop/mapred-site.xml'
end

describe package(package) do
  it { should be_installed }
end 

describe file(core_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape('<name>fs.default.name</name>') }
  its(:content) { should match Regexp.escape('<value>hdfs://localhost/</value>') }
end

describe file(hdfs_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape('<name>dfs.nameservices</name>') }
  its(:content) { should match Regexp.escape('<value>mycluster</value>') }
  its(:content) { should match Regexp.escape('<name>dfs.replication</name>') }
  its(:content) { should match Regexp.escape('<value>1</value>') }
  its(:content) { should match Regexp.escape('<name>dfs.datanode.data.dir</name>') }
  its(:content) { should match Regexp.escape("<value>file://#{ db_dir }/dfs/data</value>") }
end

describe file(mapred_site_xml) do
  it { should be_file }
  its(:content) { should match Regexp.escape('<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>') }
  its(:content) { should match Regexp.escape('<name>mapred.job.tracker</name>') }
  its(:content) { should match Regexp.escape('<value>localhost:9001</value>') }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 775 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
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

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
