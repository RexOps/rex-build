#
# vim: set ft=perl:
#

use Rex -feature => '0.42';
use Test::More;
use Rex::Commands::Partition;
use Rex::Commands::Gather;
use Data::Dumper;

do "auth.conf";

desc "Prepare System";
task "test", group => "test", sub {
  
  if(is_linux) {
    my $testimg = "/parttest.img";

    run "dd if=/dev/zero of=$testimg bs=1 count=0 seek=1G";
    is($?, 0, "Created $testimg");

    run "losetup /dev/loop0 $testimg";
    is($?, 0, "losetup for $testimg");

    my $clearpart_gpt = 0;
    eval {
      clearpart "loop0",
        initialize => "gpt";
      $clearpart_gpt = 1;
    };

    is($clearpart_gpt, 1, "clearpart gpt");

    run "losetup -d /dev/loop0";

    my $script = q|
    my $testimg = $ARGV[0];
    open(my $fh, "<", $testimg) or die($!);
    my $x;
    read($fh, $x, 1000);
    close($fh);
    if($x =~ m/EFI/) { exit 0; }
    exit 1;
    |;

    file "/testpart.pl",
      content => $script;

    run "perl /testpart.pl $testimg";
    is($?, 0, "Found EFI record. (disk initialized)");

    unlink $testimg;

    run "dd if=/dev/zero of=$testimg bs=1 count=0 seek=1G";
    run "losetup /dev/loop0 $testimg";

    my $clearpart_bios_boot = 0;
    eval {
      clearpart "loop0",
        initialize => "gpt",
        bios_boot  => TRUE;

      $clearpart_bios_boot = 1;
    };

    is($clearpart_bios_boot, 1, "cleared partition, created bios boot part");

    mkdir "/mnt/root";

    partition "/mnt/root",
      fstype  => "ext3",
      size    => 100,
      ondisk  => "loop0",
      type    => "primary";

    my $out = run "parted $testimg print | grep ext3";
    like($out, qr/^ 2 /, "found partition 2");

    run "losetup -d /dev/loop0";
    unlink $testimg;

    run "dd if=/dev/zero of=$testimg bs=1 count=0 seek=1G";
    run "losetup /dev/loop0 $testimg";

    clearpart "loop0",
      initialize => "gpt",
      bios_boot  => TRUE;

    partition "/mnt/root",
      fstype  => "ext3",
      size    => 100,
      ondisk  => "loop0",
      vg      => "vg0";

    $out = run "vgs | grep vg0";
    like($out, qr/^  vg0/, "found volume group vg0");
    $out = run "pvs | grep vg0";
    like($out, qr/^  \/dev\/loop0p2/, "found pvs for vg0");

    run "vgremove vg0";
    run "pvremove /dev/loop0p2";

    run "losetup -d /dev/loop0";
    unlink $testimg;
  }
  else {
    ok(1==1, "no tests for this os");
  }

  done_testing();
};

1;