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
        # env COMPRESSION=NONE HBASE_HOME=/usr/local/hbase /usr/local/share/opentsdb/tools/create_table.sh
        # XXX java.net.InetAddress.getLocalHost throws an exception without this
        - shell: echo "127.0.0.1 localhost {{ ansible_hostname }}" > /etc/hosts
          changed_when: False
      roles:
        - ansible-role-hadoop-datanode
      vars:
        hadoop_config:
          core_site:
            - [ name: fs.default.name, value: 'hdfs://localhost/' ]
          hdfs_site:
            - [ name: dfs.nameservices, value: mycluster ]
            - [ name: dfs.replication,value: 1 ]
            - 
              - name: dfs.datanode.data.dir
              - value: "file://{{ hadoop_datanode_dfs_datanode_data_dir }}"
          mapred_site:
            - [ name: mapred.job.tracker, value: "localhost:9001" ]

License
-------

BSD

Author Information
------------------

Tomoyuki Sakurai <tomoyukis@reallyenglish.com>
