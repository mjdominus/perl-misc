# -*- cperl -*-

package Searcher;

sub new {
  my ($class, $arg) = @_;
  my $self = { %$arg };
  bless $self => $class;
}

sub children {
  my $self = shift;
  $self->{children}->(@_);
}

sub winner {
  my $self = shift;
  $self->{winner}->(@_);
}

sub to_str {
  my $self = shift;
  $self->{to_str}->(@_);
}

package Search;

sub new_search {
  my ($class, $searcher, $queue, $args) = @_;
  bless { S => $searcher, Q => $queue, N => 0, %$args } => $class;
}

sub next {
  my ($self) = @_;
  my $dfs = $self->{DFS};

  while (@{$self->{Q}}) {
    $self->{N}++;
    my $node = shift @{$self->{Q}};
    if ($self->{trace} && $self->{N} % $self->{trace} == 0) {
      warn "handling node $self->{N}:\n", $self->{S}->to_str($node), "\n";
    }
    my @new = $self->{S}->children($node);
    if ($dfs) {
      unshift @{$self->{Q}}, @new;
    } else {
      push @{$self->{Q}}, @new;
    }
    return $node if $self->{S}->winner($node);
  }
  return;
}

1;
