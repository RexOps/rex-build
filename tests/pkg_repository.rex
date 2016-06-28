# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;

do "auth.conf";

task test => group => test => sub {

  my $op = operating_system;

  my $repo_options = {
    #Ubuntu => {
    #},
    CentOS => {
      url    => 'http://rex.linux-files.org/CentOS/$releasever/rex/$basearch/',
      gpgcheck => 0,
    },
    #SuSE => {
    #  url    => 'http://rex.linux-files.org/OpenSuSE/' . operating_system_release . '/x86_64/',
    #},
    #Debian => {
    #},
    #Mageia => {
    #},
    #Gentoo => {
    #},
    #ALT => {
    #},
    #Sientific => {
    #},
    #Redhat => {
    #},
    OpenWrt => {
      url    => 'http://downloads.openwrt.org/snapshots/trunk/ar71xx/packages/',
    },
  };


  if(! exists ($repo_options->{$op}) ) {
    print STDERR "no test for $op yet.\n";
    ok(1==1, "no test for $op yet.");
  }
  else {
    eval {
      repository add => "test", %{ $repo_options->{$op} };
      1;
    };

    ok(! $@, "repository added.");
  }

  done_testing();
};
