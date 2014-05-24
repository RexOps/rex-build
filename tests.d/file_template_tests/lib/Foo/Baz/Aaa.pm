package Foo::Baz::Aaa;

use Rex -base;

task test => sub {

  my $x = template('@test.tpl', name => 'foo');
  ok($x =~ m/one more test: foo/ms, 'template in data section (Foo/Baz.pm)');

};

1;

__DATA__

@test.tpl
one more test: <%= $name %>
@end
