#!/usr/bin/perl
#
# Assign the numbers 1..12 to edges of a cube so that
# each face adds to 26
use Search;

# edges are named A .. L

my @faces = ( [qw(A B E I)], [qw(B C F J)],
              [qw(C D G K)], [qw(A D H L)],
              [qw(E F G H)], [qw(I J K L)],
             );

my %f_containing; # maps edges to the faces that contain them
for my $face (@faces) {
  for my $edge (@$face) {
    push @{$f_containing{$edge}}, $face;
  }
}

# Nodes contain:
# map: hash mapping from edges to assigned values
# used: array recording $a[$n] = true if $n has already been assigned
# n_left:  number of unassigned
# next_edge: name of next edge to assign
my $root = [ {A => 1}, [undef, 1], 11, "B" ]; # assign A=>1 WLOG
sub vmap { $_[0][0] }
sub used { $_[0][1] }
sub n_left { $_[0][2] }
sub next_edge { $_[0][3] }

sub children {
  my ($node) = @_;
  return if n_left($node) == 0;
  my $next = next_edge($node);
  my @children;
  for my $n (unused($node)) {
    next unless try_assign(vmap($node), $next, $n);
    push @children, new_node($node, $next, $n);
  }
  return @children;
}

sub unused {
  my ($node) = @_;
  my $used = used($node);
  grep !$used->[$_], 1..12;
}

# given a map, check the face conditions when assigning $n to
# unassigned edge $edge
sub try_assign {
  my ($map, $edge, $n) = @_;
  my %new_map = (%$map, $edge => $n);
  for my $face (@{$f_containing{$edge}}) {
    return unless face_okay($face, \%new_map);
  }
  return 1;
}

# Check the face condition of the specified face
sub face_okay {
  my ($face, $map) = @_;
  my $total = 0;
  for my $e (@$face) {
    return 1 if ! defined $map->{$e};  # unassigned edge == still okay
    $total += $map->{$e};
  }
  return $total == 26;
}

# take node and assign $n to edge $next; return new node
sub new_node {
  my ($node, $next, $n) = @_;
  my ($map, $used, $n_left) = @$node;
  my %new_map = (%$map, $next => $n);
  my @new_used = @$used; $new_used[$n] = 1;
  return [ \%new_map, \@new_used, $n_left-1, chr(ord($next)+1) ];
}

sub winner {
  my ($node) = @_;
  n_left($node) == 0;
}

sub to_str {
  my ($node) = @_;
  my $map = vmap($node);
  my $f = "%2d    %2d    %2d    %2d\n";
  sprintf "   $f$f   $f",
    @{$map}{qw(E F G H), qw(A B C D), qw(I J K L)};
}

my $S = Searcher->new({ children => \&children,
                        winner => \&winner,
                        to_str => \&to_str,
                       });

my $search = Search->new_search($S, [$root], { DFS => 1, trace => 0 });

my $COUNT = 0;
$|=1;
while (my $win = $search->next ) {
  print to_str($win), "\n";
  $COUNT++;
}
print "TOTAL SOLUTIONS: $COUNT\n";

