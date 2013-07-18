use Rex -feature => '0.42';

use Rex::Commands::Kernel;
use Rex::Commands::Gather;
use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

desc "Load Kernel Module";
task "test", group => "test", sub {

   if(operating_system_is("SunOS")) {

      kmod load => "strmod/tun";
      my @mods = run "modinfo | grep tun";
      ok(scalar(@mods) == 1, "loaded strmod/tun");

      kmod unload => "strmod/tun";
      @mods = run "modinfo | grep tun";
      ok(scalar(@mods) == 0, "unloaded strmod/tun");

   }
   elsif(is_freebsd) {
      kmod load => "scc";

      my @mods = run "kldstat | grep scc";
      ok(scalar(@mods) == 1, "loaded scc");

      kmod unload => "scc";
      @mods = run "kldstat | grep scc";
      ok(scalar(@mods) == 0, "unloaded scc");
   }
   else {

      my $kmod = "ipmi_poweroff";

      #kmod load => "ipmi_msghandler";
      kmod load => $kmod;

      my @mods = run "lsmod |grep $kmod";
      ok(scalar(@mods) >= 1, "loaded $kmod");

      kmod unload => $kmod;

      @mods = run "lsmod |grep $kmod";
      ok(scalar(@mods) == 0, "unloaded $kmod");

   }

   done_testing();

};

