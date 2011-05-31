class java::v6 {

  case $lsbdistcodename {
    'etch' : {
      os::backported_package { 
        "sun-java6-bin":    
          ensure       => present,
          responsefile => "/var/cache/debconf/sun-java6-bin.preseed",
          require      => [Exec["apt-get_update"], File["/var/cache/debconf/sun-java6-bin.preseed"]];
        "sun-java6-jdk":    
          ensure  => present,
          require => Package["sun-java6-bin"];
        "sun-java6-jre":    
          ensure  => present,
          require => Package["sun-java6-bin"];
      }
    }
    'hardy',
    'intrepid',
    'jaunty',
    'lucid',
    'lenny' : {
      package { 
        "sun-java6-bin":
          ensure       => present,
          responsefile => "/var/cache/debconf/sun-java6-bin.preseed",
          require      => [Exec["apt-get_update"], File["/var/cache/debconf/sun-java6-bin.preseed"]];
        "sun-java6-jdk":
          ensure => present,
          require => Package["sun-java6-bin"];
        "sun-java6-jre":
          ensure  => present,
          require => Package["sun-java6-bin"];
      }
    } 
  }

  case $operatingsystem {
    'centos': {
       include yum::repo::jpackage::generic
       include yum::repo::jpackage::rhel
       $jdkpackagename = "java-1.6.0-openjdk"
       package {$jdkpackagename:
           ensure	=> present
       }
       package {"$jdkpackagename-devel":
           ensure	=> present
       }
     }
     default: {
       $jdkpackagename = "sun-java6-bin"
       # Thanks to Java strange licensing
       file {"/var/cache/debconf/sun-java6-bin.preseed":
         ensure  => present,
	 content => "sun-java6-bin   shared/accepted-sun-dlj-v1-1    boolean true",
       }
     }
  }


  $jvm = '6'
  file {"/etc/profile.d/java_home":
    ensure => present,
    content => template("java/java-home.erb"),
  }
 
  # On Debian/Ubuntu status of update-java-alternatives is always 1,
  # || true is just a temporary workaround !
  exec {"set default jvm":
    command => $operatingsystem ? {
      'CentOS'		      => "update-alternatives --set java /usr/lib/jvm/jre-1.6.0-openjdk.x86_64/bin/java",
      'RedHat'                => "update-java-alternatives --set java-6-sun",
      /Debian|Ubuntu|ubuntu/  => "update-alternatives --set java /usr/lib/jvm/java-6-sun/jre/bin/java || true",
    },
    unless => 'test $(readlink /etc/alternatives/java) = /usr/lib/jvm/java-6-sun/jre/bin/java',
    require => Package[$jdkpackagename],
  }

}
