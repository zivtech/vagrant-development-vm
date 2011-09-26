group { 'puppet':
  ensure => present,
}

$mysqlpassword = 'pass'
# passwords must always be actual hashes as used on disk in /etc/shadow
$webadminpassword = '$6$bCysFszn$Ycq5zFTrRm8QOWKWJk9qAr94okYBVLiQm/tcWe9dT6ohuFl46i8DoWP.LMdYJG7dQyFJh0XgDGeiWhnHUHLKF.'
$rootpassword = $webadminpassword
$backuppassword = $webadminpassword
include zivtechbase
include stylomatic
include solr
include php53-dev
include mysql5