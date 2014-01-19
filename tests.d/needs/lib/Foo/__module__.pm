#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Foo;

use Rex -base;

task "setup", sub {

   needs main "need_test";

   needs "need_test2";

};


task "need_test2", sub {

   set NEEDED2 => 1;

};

1;
