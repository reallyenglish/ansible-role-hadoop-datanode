ansible-role-hadoop-datanode
============================

Install datanode of hadoop.

Requirements
------------

None

Role Variables
--------------

| variable | description | default |
|----------|-------------|---------|
| hadoop\_datanode\_user | datanode user | "{{ \_\_hadoop\_datanode\_user }}" |
| hadoop\_datanode\_group | datanode group | "{{ \_\_hadoop\_datanode\_group }}" |
| hadoop\_datanode\_log\_dir | path to log dir | /var/log/hadoop |
| hadoop\_datanode\_db\_dir | path to db dir | "{{ \_\_hadoop\_datanode\_db\_dir }}" |
| hadoop\_datanode\_service | service name | "{{ \_\_hadoop\_datanode\_service }}" |
| hadoop\_datanode\_conf\_dir | path to config dir | "{{ \_\_hadoop\_datanode\_conf\_dir }}" |
| hadoop\_datanode\_flags | not used | "" |
| hadoop\_datanode\_dfs\_datanode\_data\_dir | path to dfs.datanode.data.dir | "{{ hadoop\_datanode\_db\_dir }}/dfs/data" |
| hadoop\_datanode\_core\_site\_file | path to core-site.xml | "{{ hadoop\_datanode\_conf\_dir }}/core-site.xml" |
| hadoop\_datanode\_hdfs\_site\_file | path to hdfs-site.xml | "{{ hadoop\_datanode\_conf\_dir }}/hdfs-site.xml" |
| hadoop\_datanode\_mapred\_site\_file | path to mapred-site.xml | "{{ hadoop\_datanode\_conf\_dir }}/mapred-site.xml" |
| hadoop\_config | a hash of xml config (see the example below) | {} |


Dependencies
------------

dict2xml is bundled in the role, with modifications, mostly removing six dependency. dict2xml is available at https://github.com/delfick/python-dict2xml.

Example Playbook
----------------

  - hosts: all
    pre_tasks:
      # XXX java.net.InetAddress.getLocalHost throws an exception without this
      - shell: echo "127.0.0.1 localhost {{ ansible_hostname }}" > /etc/hosts
        changed_when: False
    roles:
      - ansible-role-hadoop-namenode
    vars:
      hadoop_config:
        core_site:
          - 
            - name: fs.defaultFS
            - value: 'hdfs://localhost/'
          -
            - name: hadoop.tmp.dir
            - value: /var/db/hadoop
          -
            - name: io.file.buffer.size
            - value: 131072
        hdfs_site:
          -
            - name: dfs.namenode.name.dir
            - value: "${hadoop.tmp.dir}/dfs/name"
          - 
            - name: dfs.blocksize
            - value: 268435456
          -
            - name: dfs.namenode.handler.count 
            - value: 100
          -
            - name: dfs.datanode.data.dir
            - value: "${hadoop.tmp.dir}/dfs/data"
        yarn-site:
          -
            - name: yarn.acl.enable
            - value: false
          -
            - name: yarn.admin.acl
            - value: "*"
          -
            - name: yarn.log-aggregation-enable
            - value: false
        mapred_site:
          -
            - name: mapreduce.framework.name
            - value: local
          -
            - name: mapreduce.map.java.opts
            - value: "-Xmx512M"

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
