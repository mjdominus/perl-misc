#!/usr/bin/perl

use Search;
$|=1;

my $N = 3;  # square size
my $max = $N - 1; # maximum row or column number
my $target = $N * ($N * $N + 1) / 2;  # Magic sum
# nodes consist of:
# square => 4 x 4 array, partly filled in
# used => array mapping 1 .. 16 to used (true) / unused (false)
# n_empty => 16 .. 0

my $sq = [];
$sq->[$_] = [(undef) x $N] for 0 .. $max;  # empty square to start
my $root = { square => $sq,
	     used => [],
	     n_empty => $N * $N,
	   };

# Is n between 1 and N^2?
sub is_legal_number {
  my ($n) = @_;
  return 1 if $n >= 1 && $n <= $N * $N;
}

sub sumof (&@) {
  my ($f, @a) = @_;
  my $total = 0;
  for my $e (@a) {
    local $_ = $e;
    $total += $f->($e);
  }
  return $total;
}

sub children {
  my ($node) = @_;
  return if $node->{n_empty} == 0;
  $DB::single = 1 if $node->{n_empty} == 1;
  my @children;

  # [$r, $c]
  my $next_space = next_space($node->{square});

  # special-case the upper-left entry
  if ($next_space->[0] == 0 && $next_space->[1] == 0) {
    push @children, new_node($next_space, $node, $_) for 1 .. 5;
    return @children;
  }

  if (0) {
  # finishing a row or column, must satisfy magic sum requirement
  my ($required_row_number, $required_col_number);
  if ($next_space->[0] == $max) { # last row
    my $col_sum = col_sum($node->{square}, $next_space->[1]);
    $required_col_number = $target - $col_sum;
  }
  if ($next_space->[1] == $max) { # last column
    my $row_sum = row_sum($node->{square}, $next_space->[0]);
    $required_row_number = $target - $row_sum;
  }
  return if defined $required_row_number &&
            defined $required_col_number &&
	    $required_row_number != $required_col_number;
  my $required_number = $required_row_number // $required_col_number;
  if (defined $required_number) {
    if (is_legal_number($required_number) &&
	! $node->{used}->[$required_number]) {
      return new_node($next_space, $node, $required_number);
    } else {
      return;  # can't finish this column
    }
  }
}

  # Try all remaining numbers
  for my $n (unused_numbers($node->{used})) {
    push @children, new_node($next_space, $node, $n);
  }
  return @children;
}

sub row_sum {
  my ($sq, $row) = @_;
  return sumof { $sq->[$row][$_] } (0 .. $max);
}

sub col_sum {
  my ($sq, $col) = @_;
  return sumof { $sq->[$_][$col] } (0 .. $max);
}

sub unused_numbers {
  my ($used) = @_;
  my @unused;
  for my $n (1 .. $N*$N) {
    push @unused, $n if not $used->[$n];
  }
  return @unused;
}

# next best space to fill in square:
# always add to the row or column with the most filled spaces already;
# otherwise choose the upperleftmost
sub next_space {
  my ($sq) = @_;
  my $fullest_row_or_col = "R";
  my $which_row_or_col = 0;
  my $fullness = 0;
  for my $row (0 .. $max) {
    my $r = $sq->[$row];
    my $filled = sumof { defined($_) ? 1 : 0 } @$r;
    if ($filled > $fullness && $filled < $N) {
      $which_row_or_col = $row;
      $fullness = $filled;
    }
  }
  for my $col (0 .. $max) {
    my $filled = sumof { defined($sq->[$_][$col]) ? 1 : 0 } (0 .. $max);
    if ($filled > $fullness && $filled < $N) {
      $fullest_row_or_col = "C";
      $which_row_or_col = $col;
      $fullness = $filled;
    }
  }

  if ($fullest_row_or_col eq "R") {
    for my $c (0 .. $max) {
      if (! defined $sq->[$which_row_or_col][$c]) {
	return [$which_row_or_col, $c];
      }
    }
  } else {
    for my $r (0 .. $max) {
      if (! defined $sq->[$r][$which_row_or_col]) {
	return [$r, $which_row_or_col];
      }
    }
  }

  $DB::single = 1;
  1;
}


sub new_node {
  my ($next_space, $node, $n) = @_;
  my @sq = @{$node->{square}};
  my ($r, $c) = @$next_space;
  $sq[$r] = [ @{$sq[$r]} ];  # copy row
  $sq[$r][$c] = $n;

  return if row_failed(\@sq, $r) || col_failed(\@sq, $c);

  my @used = @{$node->{used}};
  $used[$n] = 1;
  return { square => \@sq,
	   used => \@used,
	   n_empty => $node->{n_empty} - 1,
	 };
}

sub row_failed {
  my ($sq, $r) = @_;
  my $total = 0;
  for my $c (0 .. $max) {
    return if not defined $sq->[$r][$c];
    $total += $sq->[$r][$c];
  }
  return $total != $target;
}

sub col_failed {
  my ($sq, $c) = @_;
  my $total = 0;
  for my $r (0 .. $max) {
    return if not defined $sq->[$r][$c];
    $total += $sq->[$r][$c];
  }
  return $total != $target;
}

sub winner {
  my ($node) = @_;
  return $node->{n_empty} == 0;
}

sub to_str {
  my ($node, $prefix) = @_;
  $prefix //= "";
  my $sq = $node->{square};
  my $s;
  for my $row (@$sq) {
    my $rs = join " ", map { defined($_) ? sprintf("%2d", $_) : "--" } @$row;
    $s .= "$prefix$rs\n";
  }
  return $s;
}

# Typical node:
# [ target sum, used, remaining pool ]
my $S = Searcher->new({ children => \&children,
                        winner => \&winner,
                        to_str => \&to_str,
                       });

my $search = Search->new_search($S, [$root], { DFS => 1, trace => 0 });

my $COUNT = 0;
while (my $win = $search->next ) {
  print "SQUARE:\n", to_str($win, "| ");
  my $h = to_str($win);
  if ($SEEN{$h}++) {
    print "*** Already seen!\n";
  }
  $COUNT++;
}

print "$COUNT squares found\n";

