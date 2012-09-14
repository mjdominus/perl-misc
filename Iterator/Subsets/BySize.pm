#!/usr/bin/perl
use strict;

#
# Hi Larry!
# I implemented that subset-generating iterator you asked about.
# It turned out to be simpler than I expected.
# As usual, most of the code here is not really interesting.
# The crucial part of the code is the "vector" subroutine.
# This is the interesting algorithm.
# The rest is just fiddling around with the iterators.
#
# To demonstrate this, run this file as a program.
# It has a canned set with six elements.
# If you run "Subsets.pm 2 3 4 " it will generate all the subsets with
# 2, 3, or 4 elements.
#
# Enjoy!

package Iterator::Subsets::BySize;
use Carp qw(confess);

unless (caller) {
  my @sizes = @ARGV;
  my $it = subsets_of_these_sizes([qw(red orange yellow green blue violet)], @sizes);
  while (my $subset = $it->()) {
    print "@$subset\n";
  }
}

sub Iterator (&) { $_[0] }

# It would be simpler to use concat(map subsets_of_size_n($S, $_), @sizes) here
sub subsets_of_these_sizes {
  my ($S, @sizes) = @_;
  my $it = @sizes && subsets_of_size_n($S, shift(@sizes));
  return Iterator {
    while ($it || @sizes) {
      my $subset = $it->();
      return $subset if $subset;
      $it = @sizes && subsets_of_size_n($S, shift(@sizes))
    }
    return;
  };
}

# iterate subsets of size k of elements of $S
# It would be simpler to use imap {} upto(...) here.
sub subsets_of_size_n {
  my ($S, $k) = @_;
  my $N = @$S;
  my $p = choose($N, $k)-1;
  return Iterator {
    $p < 0 ? undef
           : _select([vector($N, $k, $p--)], $S);
  };
}

# Take a set of size N, and a vector of zeroes and ones of the same size,
# and extract the corresponding elements from the set
sub _select {
  my ($selection, $S) = @_;
  my $N = @$S;
  my @result;
  for my $i (0 .. $N-1) {
    push @result, $S->[$i] if $selection->[$i];
  }
  return \@result;
}

# This is the crucial algorithm
#
# Generate the $p'th vector of $n bits of which exactly $k are ones
# (That is, each generated vector will be different for each value of
#  $p between 0 and ($n choose $k)-1.)
sub vector {
  my ($n, $k, $p) = @_;
#  warn "vector($n, $k, $p)\n";
  confess "p=$p out of range for ($n, $k)" if $p < 0 || $p >= choose($n, $k);
  1;
  return () if $n == 0;
  # Is the first bit 0 or 1?
  # Of the (n choose k) vectors, the first (n-1 choose k) begin with 0
  # and the remaining (n choose k) begin with 1
  my $first = 0 + ($p >= choose($n-1, $k));
  my @rest = vector($n-1, $k - $first, $first ? $p - choose($n-1, $k): $p);
  return ($first, @rest);
}

# This calculates binomial coefficients in amortized constant time
my @p;
sub choose {
  my ($n, $k) = @_;
  return 0 if $n < 0 || $k < 0;
  my $row = $p[$n] ||= [1];
  until (@$row > $k) {
    my $kk = @$row;
    push @$row, choose($n-1, $kk-1) * $n / $kk;
  }
#  warn "choose($n, $k) = $row->[$k]\n";
  return $row->[$k];
}



1;
