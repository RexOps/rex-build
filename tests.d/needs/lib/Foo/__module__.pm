#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Foo;

use Rex -base;

task "setup", sub {

   needs main "need_test";

};

1;
