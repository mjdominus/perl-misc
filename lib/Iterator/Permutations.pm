package Iterator::Permutations;

use Carp qw(confess croak);
use strict;

sub new {
  my ($class, $arg) = @_;
  my @items;
  if ($arg->{items}) { @items = @{$arg->{items}} }
  elsif ($arg->{n})  { @items = (1 .. $arg->{n}) }
  else { croak "$class\::new missing 'items' argument" }
  my $self = bless { items => \@items, o => [ (0) x @items ] } => $class;
  $self->permutation;
  return $self;
}

sub next {
  my ($self) = @_;
  return if $self->done;
  my $result = $self->permutation;
  $self->increment_odometer;
  return wantarray ? @$result : $result;
}

sub increment_odometer {
  my ($self) = @_;
  return if $self->{done};
  my $o = $self->{o};
  my $i;
  for ($i = 0; $i < @$o; $i++) {
    $o->[$i]++;
    if ($o->[$i] > $i) {
      $o->[$i] = 0;
    } else {
      last;
    }
  }
  $self->{done} = 1 if $i == @$o;
  delete $self->{current_permutation};
}

sub permutation {
  my ($self) = @_;
  unless ($self->{current_permutation}) {
    my @perm;
    my @items = $self->items;
    for my $i (reverse $self->odometer) {
      push @perm, splice @items, $i, 1;
    }
    $self->{current_permutation} = \@perm;
  }
  return wantarray ? @{$self->{current_permutation}} : $self->{current_permutation};
}

sub items {
  my ($self) = @_;
  @{$self->{items}};
}

sub odometer {
  my ($self) = @_;
  @{$self->{o}};
}

sub done { $_[0]{done} }

1;
