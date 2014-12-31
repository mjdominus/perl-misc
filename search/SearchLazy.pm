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

package SearchLazy;

sub new_search {
  my ($class, $searcher, $queue, $args) = @_;
  bless { S => $searcher, Q => [list_it(@$queue)], N => 0, %$args } => $class;
}

sub list_it {
  my @i = @_;
  return sub { shift @i };
}

sub next {
  my ($self) = @_;
  my $dfs = $self->{DFS};
  while ($self->{Q}) {
    $self->{N}++;
    my $node;
    while (@{$self->{Q}}) {
        last if defined($node = $self->{Q}[0]->());
        shift @{$self->{Q}}; # discard exhausted iterator
    }
    return unless defined $node;
    if ($self->{trace} && $self->{N} % $self->{trace} == 0) {
      warn "handling node $self->{N}:\n", $self->{S}->to_str($node), "\n";
    }
    my @children = $self->{S}->children($node);
    my $child_it;
    if (@children == 1 && ref $children[0] eq "CODE") {
      $child_it = $children[0];
    } else {
      $child_it = list_it(@children);
    }
    if ($dfs) {
      unshift @{$self->{Q}}, $child_it;
    } else {
      push @{$self->{Q}}, $child_it;
    }
    return $node if $self->{S}->winner($node);
  }
  return;
}

1;
