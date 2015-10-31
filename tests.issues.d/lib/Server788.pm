package Server788 {

  use common::sense;

  use Rex -base;
  use Data::Dumper;
  
  use parent qw(Rex::Group::Entry::Server);
  
  sub new {
    my $that = shift;
    my $proto = ref($that) || $that;
    my $self = $proto->SUPER::new(@_);
    
    bless($self, $proto);
  
    return $self;
  }

  sub get_user {
    my $self = shift;
    return $self->{auth}->{user};
  }

}

1;
