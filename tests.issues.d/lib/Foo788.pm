package Foo788 {

#  use Rex -base;
  require Rex::Commands;
  use Rex::Commands::Run;
  
  sub new {
    my $that = shift;
    my $proto = ref($that) || $that;
    my $self = {@_};

    bless($self, $proto);
  }
  
  sub get_user {
    my ($self) = @_;

    my $x = Rex::Commands::run_task ("Foo788:t_user", on => $self->{server});
    return $x;
  }
  
  
  Rex::Commands::task("t_user", sub {
    my $s = run "id -un";
    return $s;
  });

}

1;
