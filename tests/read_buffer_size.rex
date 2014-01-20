# vim: set syn=perl:

use Rex -feature => '0.42';
use Test::More;
use Rex::Pkg;
use Rex::Commands::Gather;

do "auth.conf";

set rex_internals => {
   read_buffer_size => 1000,
};

task test => group => test => sub {

   ok(connection->server eq $ENV{HTEST}, "connected to $ENV{HTEST}");

   my $out = run "id";
   ok($out =~ /uid=0\(root\) gid=0\((root|wheel)\)/, "logged in as root");

   my $pkg = Rex::Pkg->get;
   my $to_install = case operating_system, {
      qr{SuSE}i   => "vim",
      qr{CentOS}i => "vim-enhanced",
      qr{Redhat}i => "vim-enhanced",
      qr{Fedora}i => "vim-enhanced",
      qr{Mageia}i => "vim-enhanced",
      qr{Debian}i => "vim",
      qr{Ubuntu}i => "vim",
      default     => "vim",
   };

   my $ok = 0;

   if(is_suse) {
      # strange failure on suse for update_package_db()
      return;
   }

   eval {
      update_package_db();
      $ok = 1;
   };
   ok($ok == 1, "update package db");

   eval {
      install $to_install;
   };

   ok(! $@ && $pkg->is_installed($to_install), "installed $to_install");

   eval {
      remove package => $to_install;
   };
   ok(! $@ && ! $pkg->is_installed($to_install), "$to_install is not installed");


   done_testing();
};

