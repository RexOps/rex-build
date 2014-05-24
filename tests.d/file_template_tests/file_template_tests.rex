# vim: set syn=perl:
use Rex -feature => 0.42;
use Test::More;

do "auth.conf";

require Foo;
use Foo::Baz;
use Foo::Baz::Aaa;

task "test", group => "test", sub {

  my $x = template('@test.tpl', name => 'foo');
  ok($x =~ m/this is a test: foo!/ms, 'template in data section (Rexfile)');

  Foo::bar();
  Foo::Baz::test();
  Foo::Baz::Aaa::test();

  done_testing();
};

1;


__DATA__

@test.tpl
this is a test: <%= $name %>!
@end
