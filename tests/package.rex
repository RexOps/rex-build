#
# vim: set ft=perl:
#

use Rex -feature => '0.42';
use Test::More;
use Rex::Hardware;
use Rex::Commands::Pkg;
use Rex::Commands::Gather;
use Data::Dumper;
use Rex::Pkg;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};


desc "Prepare System";
task "test", group => "test", sub {
   
   my $pkg = Rex::Pkg->get;
   my $to_install = case operating_system, {
      qr{SuSE}i   => "vim-enhanced",
      qr{CentOS}i => "vim-enhanced",
      qr{Redhat}i => "vim-enhanced",
      qr{Mageia}i => "vim-enhanced",
      qr{Debian}i => "vim",
      qr{Ubuntu}i => "vim",
   };

   my $ok = 0;

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

