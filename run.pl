#!/usr/bin/env perl

use Data::Dumper;
use Rex -base;
use Rex::Commands::Virtualization;
use Rex::Commands::SimpleCheck;

set virtualization => "LibVirt";

$::QUIET = 1;

my $base_vm = $ARGV[0];

my $new_vm = "${base_vm}-test";

vm clone => $base_vm  => $new_vm;

vm start => $new_vm;

my $vminfo = vm guestinfo => $new_vm;
my $ip = $vminfo->{network}->[0]->{ip};

while(! is_port_open($ip, 22)) {
   sleep 1;
}

system "HTEST=$ip prove --formatter TAP::Formatter::JUnit --ext rex -e rex-test";

vm destroy => $new_vm;

vm delete => $new_vm;


