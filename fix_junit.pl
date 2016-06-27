#!/usr/bin/env perl

use strict;
use warnings;

use XML::Simple;

my $os = join(" ", @ARGV);

opendir(my $dh, ".") or die($!);
while(my $entry = readdir($dh)) {
  next if($entry !~ m/\.xml$/);
  
  my $s = eval { local(@ARGV, $/) = ($entry); <>; };
  my $ref = XMLin($s, KeepRoot => 1, ForceArray => ['system-out', 'system-err']);
  if($ref->{testsuites}->{testsuite}->{tests} == 0) {
    $ref->{testsuites}->{testsuite}->{failures} = 1;
    $ref->{testsuites}->{testsuite}->{errors} = 1;
    $ref->{testsuites}->{testsuite}->{"system-out"} = $ref->{testsuites}->{testsuite}->{"system-out"} . "\nNo tests run\n";
  }
      
  my $new_testcase = {};
  
  for my $tc (keys %{ $ref->{testsuites}->{testsuite}->{testcase} }) {
    $new_testcase->{"$os-$tc"} = $ref->{testsuites}->{testsuite}->{testcase}->{$tc};
  }
  
  $ref->{testsuites}->{testsuite}->{testcase} = $new_testcase;
  
  my $o = XMLout($ref, KeepRoot => 1);
  open(my $fh, ">", $entry) or die($!);
  print $fh $o;
  close($fh);
}
closedir($dh);

