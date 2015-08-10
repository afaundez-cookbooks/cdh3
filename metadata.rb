name             'cdh3'
maintainer       'Álvaro Faúndez'
maintainer_email 'alvaro@faundez.net'
license          'All rights reserved'
description      'Installs/Configures CDH3'
long_description 'Installs/Configures a single node cluster with Cloudera Dristribution Hadoop 3'
version          '0.1.0'

depends 'yum', '~> 3.6.3'
depends 'mysql', '~> 6.0'
depends 'mysql2_chef_gem', '~> 1.0'

supports 'ubuntu', '=14.04'
supports 'centos', '=6.1'
