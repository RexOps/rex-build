use Rex -feature => '0.42';
use Rex::Commands::Cron;

use Test::More;

user $ENV{REXUSER};
password $ENV{REXPASS};
pass_auth;

if(exists $ENV{use_sudo}) {
   sudo_password $ENV{REXPASS};
   sudo -on;
}

group test => $ENV{HTEST};

task test => group => test => sub {

   install "dmidecode";

   my $dmi = Rex::Inventory::Bios::get();

   ok($dmi, "initialize dmi object");

   my $bios = $dmi->get_bios;
   if($bios->get_vendor eq "Bochs") {
      ok($bios->get_vendor eq "Bochs", "got bios vendor bochs");
   }
   else {

      my $bb = $dmi->get_base_board;
      #   
      #say "bb manuf: " . $bb->get_manufacturer;
      ok($bb->get_manufacturer eq "Parallels Software International Inc." || $bb->get_manufacturer eq "Intel Corporation", "base board get manufacturer");

      #say "sn: " . $bb->get_serial_number;
      #say "version: " . $bb->get_version;
      #say "product name: " . $bb->get_product_name;
      ok($bb->get_product_name eq "Parallels Virtual Platform" || $bb->get_product_name eq "440BX Desktop Reference Platform", "base board get product name");
   #
   #
   #say "bios vendor: " . $bios->get_vendor;
   #   say "bios version: " . $bios->get_version;
   #   say "bios release: " . $bios->get_release_date;

      ok($bios->get_vendor eq "Parallels Software International Inc." || $bios->get_vendor eq "Phoenix Technologies LTD", "bios get vendor");
      ok($bios->get_version =~ /\d\.0\./ || $bios->get_version eq "6.0.12094.676533" || $bios->get_version eq "6.00", "bios version");
      ok($bios->get_release_date eq "10/26/2007" || $bios->get_release_date eq "12/31/2009", "bios release date");


      my @cpus = $dmi->get_cpus;
      ok($cpus[0]->get_max_speed eq "2800 MHz" || $cpus[0]->get_max_speed eq "30000 MHz" || $cpus[0]->get_max_speed eq "2800MHz", "cpu get max speed");

      my @mems = $dmi->get_memory_modules;
      ok($mems[0]->get_size eq "512 MB" || $mems[0]->get_size eq "1024 MB" || $mems[0]->get_size eq "1073741824 bytes", "memory size");
    
      my @mema = $dmi->get_memory_arrays;
      ok($mema[0]->get_maximum_capacity eq "8 GB" || $mema[0]->get_maximum_capacity eq "256 GB" || $mema[0]->get_maximum_capacity eq "8589934592 bytes", "memory array max capacity");

      my $sysinfo = $dmi->get_system_information;
      #  say $sysinfo->get_manufacturer;
      #say $sysinfo->get_product_name;

      ok($sysinfo->get_manufacturer eq "Parallels Software International Inc." || $sysinfo->get_manufacturer eq "VMware, Inc.", "system information manucafturer");
      ok($sysinfo->get_product_name eq "Parallels Virtual Platform" || $sysinfo->get_product_name eq "VMware Virtual Platform", "system information product name");

   }

   done_testing();
};

