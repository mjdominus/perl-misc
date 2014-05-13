#!/usr/bin/perl
#
# To generate the graphs, feed the output of this program to
#   dot -Tpng  > fg.png
#

my $trimmed = $ARGV[0];

print "graph fox_goose_cereal {
  shape=ellipse;
  bcfg_ [color=green];
  _bcfg [color=blue];
";

my @queue = ({f => 0, g => 0, c => 0, b => 0});

sub st {
  my ($n) = @_;
  my @l = grep $n->{$_} == 0, sort keys %$n;
  my @r = grep $n->{$_} == 1, sort keys %$n;
  join("", @l) . '_' . join("", @r);
}

sub forbidden {
  my ($n) = @_;
  return 1 if $n->{g} == $n->{f} && $n->{g} != $n->{b};
  return 1 if $n->{g} == $n->{c} && $n->{g} != $n->{b};
  return 0;
}

sub moves {
  my ($n) = @_;
  my $b = $n->{b};
  my @m;
  for my $t (qw(f c g b)) {
    next if $n->{$t} != $b;
    my $nn = { %$n };
    $nn->{b} = $nn->{$t} = 1 - $b;
    push @m, $nn;
  }
  return @m;
}

my %seen;
while (@queue) {
  my $n = shift @queue;
  my $s = st($n);
  next if $trimmed && forbidden($n);
  print "$s [color=red];\n" if forbidden($n);
  next if $seen{$s}++;
  for my $move (moves($n)) {
    next if $trimmed && forbidden($move);
    my $ss = st($move);
    unless ($edge{join ",", sort $s, $ss}++ == 0) {
      print "$s -- $ss\n";
    }
    push @queue, $move;
  }
}

print "}\n";
