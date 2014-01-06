# vim: set syn=perl:

use Rex -feature => ['0.42', 'exec_and_sleep'];
#use Rex -feature => ['0.42'];
use Rex::Commands::Service;
use Rex::Commands::Gather;

use Test::More;

do "auth.conf";

service_provider_for SunOS => "svcadm";

desc "Get Hardware Information";
task "test", group => "test", sub {

   my $package = case operating_system, {
      qr{SuSE}i    => 'apache2',
      qr{CentOS}i  => 'httpd',
      qr{Fedora}i  => 'httpd',
      qr{Redhat}i  => 'httpd',
      qr{Ubuntu}i  => 'apache2',
      qr{Debian}i  => 'apache2',
      qr{FreeBSD}i => 'apache22',
      qr{OpenWrt}i => 'uhttpd',
      qr{Mageia}i  => 'apache',
   };

   my $service = case operating_system, {
      qr{SuSE}i    => 'apache2',
      qr{CentOS}i  => 'httpd',
      qr{Fedora}i  => 'httpd',
      qr{Redhat}i  => 'httpd',
      qr{Ubuntu}i  => 'apache2',
      qr{Debian}i  => 'apache2',
      qr{FreeBSD}i => 'apache22',
      qr{OpenWrt}i => 'uhttpd',
      qr{Mageia}i  => 'httpd',
   };

   install $package;

   service $service => "stop";

   ok(! service($service => "status"), "service is stopped");

   service $service => "start";

   ok(service($service => "status"), "service is running");

   done_testing();
};
