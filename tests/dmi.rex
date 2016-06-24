# vim: set syn=perl:
use Rex -feature => '0.42';
use Rex::Commands::Cron;

use Test::More;


do "auth.conf";

task test => group => test => sub {

  # need to be inside the task, so that is_file() is not local
  if (is_file("/.dockerinit")) {
    # skip_all doesn't seem to work with JUnit
    #plan skip_all => "Skipping dmi tests with docker" 
    ok(1==1, "Skipping dmi tests with docker");
    done_testing();
    return;
  }

  my $package = case operating_system, {
    #qr{SuSE}i   => 'pmtools',
    default    => 'dmidecode',
  };

  eval {
    install $package;
  };

  my $dmi = Rex::Inventory::Bios::get();

  ok($dmi, "initialize dmi object");

  my ($out) = run "dmidecode | wc -l";
  if($out <= 10) {
    done_testing();
    return;
  }

  my $bios = $dmi->get_bios;
  if($bios->get_vendor eq "Bochs") {
    is($bios->get_vendor, "Bochs", "got bios vendor bochs");
  }
  elsif($bios->get_vendor eq "Xen") {
    my @mema = $dmi->get_memory_arrays;
    my $sysinfo = $dmi->get_system_information;

    like($bios->get_vendor, qr/Xen/, "bios get vendor");
    like($bios->get_version, qr/\d\./, "bios version");
    like($bios->get_release_date, qr/\d+\/\d+/, "bios release date");
    like($mema[0]->get_maximum_capacity, qr/^\d/, "memory array max capacity");
    like($sysinfo->get_manufacturer, qr/Xen/, "system information manucafturer");
    like($sysinfo->get_product_name, qr/HVM domU/, "system information product name");
  }
  else {

    my $bb = $dmi->get_base_board;
    like($bb->get_manufacturer, qr/(Parallels Software International Inc.|Intel Corporation)/, "base board get manufacturer");

    like($bb->get_product_name, qr/(Parallels Virtual Platform|440BX Desktop Reference Platform)/, "base board get product name");

    like($bios->get_vendor, qr/(Parallels Software International Inc|Phoenix Technologies LTD)/, "bios get vendor");
    like($bios->get_version, qr/(\d\.0\.|6\.0)/, "bios version");
    like($bios->get_release_date, qr/(10\/26\/2007|12\/31\/2009)/, "bios release date");


    my @cpus = $dmi->get_cpus;
    like($cpus[0]->get_max_speed, qr/(2800 MHz|30000 MHz|2800MHz)/, "cpu get max speed");

    my @mems = $dmi->get_memory_modules;
    like($mems[0]->get_size, qr/(512 MB|1024 MB|1073741824 bytes)/, "memory size");

    my @mema = $dmi->get_memory_arrays;
    like($mema[0]->get_maximum_capacity, qr/(8 GB|256 GB|8589934592 bytes)/, "memory array max capacity");

    my $sysinfo = $dmi->get_system_information;
    like($sysinfo->get_manufacturer, qr/(Parallels Software International Inc|VMware, Inc\.)/, "system information manucafturer");
    like($sysinfo->get_product_name, qr/(Parallels Virtual Platform|VMware Virtual Platform)/, "system information product name");

  }

  done_testing();
};
