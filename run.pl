#!/usr/bin/env perl

use YAML;
use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;
use Cwd 'getcwd';

set virtualization => "LibVirt";


$::QUIET = 1;

my $yaml = eval { local(@ARGV, $/) = ($ENV{HOME} . "/.build_config"); <>; };
$yaml .= "\n";
my $config = Load($yaml);

my $base_vm = $ARGV[0];

Rex::connect(%{ $config });

my $new_vm = "${base_vm}-test-$$";
if(exists $ENV{use_sudo}) {
   $new_vm .= "-sudo";
}

vm clone => $base_vm  => $new_vm;

vm start => $new_vm;

my $vminfo = vm guestinfo => $new_vm;
my $ip = $vminfo->{network}->[0]->{ip};

while(! is_port_open($ip, 22)) {
   sleep 1;
}

my ($user, $pass);

if(exists $ENV{use_sudo}) {
   $user = $config->{box}->{sudo}->{user};
   $pass = $config->{box}->{sudo}->{password};
}
else {
   $user = $config->{box}->{default}->{user};
   $pass = $config->{box}->{default}->{password};
}

LOCAL {
   my $cwd = getcwd();
   my $rnd = get_random(8, 'a' .. 'z');

   $ENV{"WORK_DIR"} = "/tmp/workspace/$rnd";

   mkdir "/tmp/workspace";
   mkdir "/tmp/workspace/$rnd";
   chdir "/tmp/workspace/$rnd";

   system 'git clone git@github.com:krimdomu/Rex.git rex --branch development >/tmp/out.log 2>&1';

   chdir $cwd;

   $ENV{"PATH"} = "/tmp/workspace/$rnd/rex/bin:" . $ENV{PATH};
   $ENV{"PERLLIB"} = "/tmp/workspace/$rnd/rex/lib:" . (exists $ENV{PERLLIB} ? $ENV{PERLLIB} : "");
   $ENV{"PERL5LIB"} = "/tmp/workspace/$rnd/rex/lib:" . (exists $ENV{PERL5LIB} ? $ENV{PERL5LIB} : "");

   system "HTEST=$ip perl /tmp/workspace/$rnd/rex/bin/rex -f contrib/prepare.rex prepare >>/var/log/rex/prepare.log 2>&1";

   if($ENV{use_sudo}) {
      system "HTEST=$ip perl /tmp/workspace/$rnd/rex/bin/rex -f contrib/prepare_sudo.rex prepare >>/var/log/rex/prepare_sudo.log 2>&1";
      if($? != 0) {
         print STDERR "Error preparing for sudo.\n";
         exit 1;
      }
   }

   # run tests from tests directory
   $ENV{PATH} = getcwd() . ":" . $ENV{PATH};
   system "WORK_DIR=$ENV{WORK_DIR} REXUSER=$user REXPASS=$pass HTEST=$ip prove --formatter TAP::Formatter::JUnit --ext rex -e rex-test tests >junit_output_tests.xml";


   # run tests from tests.d directory
   opendir(my $dh, "tests.d") or die($!);
   while(my $entry = readdir($dh)) {
      next if ($entry =~ m/^\./);
      next if (! -d "tests.d/$entry");

      $ENV{PERL5LIB} = "tests.d/$entry/lib:" . (exists $ENV{PERL5LIB} ? $ENV{PERL5LIB} : "");
      system "WORK_DIR=$ENV{WORK_DIR} REXUSER=$user REXPASS=$pass HTEST=$ip prove --formatter TAP::Formatter::JUnit --ext rex -e rex-test tests.d/$entry >junit_output_testsd_$entry.xml";
   }
   closedir($dh);


   system "WORK_DIR=$ENV{WORK_DIR} REXUSER=$user REXPASS=$pass HTEST=$ip prove --formatter TAP::Formatter::JUnit --ext rex -e rex-test tests.post.d >junit_output_tests_post_d.xml";

   system "rm -rf /tmp/workspace/$rnd";
};

vm destroy => $new_vm;

vm delete => $new_vm;

#rm "/var/lib/libvirt/images/$new_vm.img";
# fix for #6
run "virsh vol-delete --pool default $new_vm.img";


sub get_random {
   my $count = shift;
   my @chars = @_;
   
   srand();
   my $ret = "";
   for(1..$count) {
      $ret .= $chars[int(rand(scalar(@chars)-1))];
   }
   
   return $ret;
}

