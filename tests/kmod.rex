# vim: set syn=perl:
use Rex -feature => '0.42';

use Rex::Commands::Kernel;
use Rex::Commands::Gather;
use Test::More;

do "auth.conf";

desc "Load Kernel Module";
task "test", group => "test", sub {

  # need to be inside the task, so that is_file() is not local
  if (is_file("/.dockerinit")) {
    # skip_all doesn't seem to work with JUnit
    #plan skip_all => "Skipping dmi tests with docker" 
    ok(1==1, "Skipping dmi tests with docker");
    done_testing();
    return;
  }

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
  } elsif (is_openwrt) {
    my $kmod = "ppp_async";

    kmod unload => $kmod;

    my @mods = run "lsmod | grep $kmod";
    ok(scalar(@mods) == 0, "unloaded $kmod");

    kmod load => $kmod;

    @mods = run "lsmod | grep $kmod";
    ok(scalar(@mods) >= 1, "loaded $kmod");
  }
  else {

    my ($out) = run "lsmod | wc -l";
    if($out == 1) {
      ok(1==1, "no tests on this box.");
      done_testing();
      return;
    }

    my $os = lc operating_system;
    my $kmod = "ipmi_poweroff";
    if($os =~ m/Gentoo/i) {
      $kmod = "ntfs";
    }

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
