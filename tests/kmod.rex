# vim: set syn=perl:
use Rex -feature => '0.42';

#use Rex::Commands::Kernel;
#use Rex::Commands::Gather;
use Test::More;
use Data::Dumper;

do "auth.conf";

desc "Load Kernel Module";
task "test", group => "test", sub {

  my $res_kernel = 0;
  for my $inc (keys %INC) {
    if($inc =~ m/Resource\/kernel/) {
      $res_kernel = 1;
      last;
    }
  }

  # need to be inside the task, so that is_file() is not local
  if (is_file("/.dockerinit")) {
    # skip_all doesn't seem to work with JUnit
    #plan skip_all => "Skipping dmi tests with docker" 
    ok(1==1, "Skipping dmi tests with docker");
    done_testing();
    return;
  }

  if($res_kernel) {
    my $kernel_mod = "fat";
    
    my $mods_loaded = sub { die "Can't test this OS."; };
    my $mods_on_boot = sub { die "Can't test this OS."; };

    if(is_linux) {
      $mods_loaded = sub {
        my ($mod) = @_;
        my @out = run "lsmod";
        my ($loaded_mod) = grep { m/^\Q$mod\E\s+/ } @out;
        if($loaded_mod) {
          return 1;
        }
        return 0;
      };
    }
    
    if(is_redhat) {
      my $os_ver = operating_system_release();
      $mods_on_boot = sub {
        my ($mod) = @_;
        if($os_ver =~ m/^[45]/) {
          my @out = run "cat /etc/rc.modules";
          my ($loaded_mod) = grep { m/^\Q$mod\E$/ } @out;
          if($loaded_mod) {
            return 1;
          }
          else {
            return 0;
          }
        }
        elsif($os_ver =~ m/^6/) {
          if(is_file("/etc/sysconfig/modules/$mod.modules")) {
            return 1;
          }
          else {
            return 0;
          }
        }
        else {
          if(is_file("/etc/modules-load.d/$mod.conf")) {
            return 1;
          }
          else {
            return 0;
          }
        }
      };
    }
    
    if($mods_loaded->($kernel_mod)) {
      run "rmmod $kernel_mod" if(is_linux);
    }

    if($mods_loaded->($kernel_mod)) {
      die "Can't clean test vm. kernel mod can't be unloaded.";
    }
    
    my $changed = 0;
    kmod $kernel_mod,
      ensure => "present",
      on_change => sub { $changed = 1; };
      
    is($changed, 1, "$kernel_mod loaded.");
    is($mods_loaded->($kernel_mod), 1, "$kernel_mod found in module list.");

    $changed = 0;
    kmod $kernel_mod,
      ensure => "absent",
      on_change => sub { $changed = 1; };
      
    is($changed, 1, "$kernel_mod unloaded.");
    is($mods_loaded->($kernel_mod), 0, "$kernel_mod NOT found in module list.");

    my $changed = 0;
    kmod $kernel_mod,
      ensure => "enabled",
      on_change => sub { $changed = 1; };
      
    is($changed, 1, "$kernel_mod enabled.");
    is($mods_on_boot->($kernel_mod), 1, "$kernel_mod found in module boot list.");

    my $changed = 0;
    kmod $kernel_mod,
      ensure => "disabled",
      on_change => sub { $changed = 1; };
      
    is($changed, 1, "$kernel_mod disabled.");
    is($mods_on_boot->($kernel_mod), 0, "$kernel_mod NOT found in module boot list.");
  }
  else {

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
      my $kmod = "fat";
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
  }
  
  done_testing();
  
};

1;

