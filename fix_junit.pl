#!/usr/bin/env perl

use strict;
use warnings;

use XML::Simple;

opendir(my $dh, ".") or die($!);
while(my $entry = readdir($dh)) {
  next if($entry !~ m/\.xml$/);
  
  my $s = eval { local(@ARGV, $/) = ($entry); <>; };
  my $ref = XMLin(KeepRoot => 1, ForceArray => ['system-out', 'system-err']);
  if($ref->{testsuites}->{testsuite}->{tests} == 0) {
    $ref->{testsuites}->{testsuite}->{failures} = 1;
    $ref->{testsuites}->{testsuite}->{errors} = 1;
    
    my $o = XMLout($ref, KeepRoot => 1);
    open(my $fh, ">", $entry) or die($!);
    print $fh $o;
    close($fh);
  }
}
closedir($dh);

