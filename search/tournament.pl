#!/usr/bin/perl

use Search;
$|=1;

# nodes consist of:
# table "A,B" => have A and B met?
# current seatings: [ [A,B,C], ... ]
# next unseated this round  "A"
# previous seatings [ complete seatings... ]
# name of last person "F"
# current seating number
# target number of seatings 23
# number of tables
# people_per_table

# Four people, two tables of two each
my $root = [ {"A,B" => 1,
              "B,A" => 1,
              "C,D" => 1,
              "D,C" => 1, },
             [],
             "A",
             [ [ [qw(A B)], [qw(C D)] ] ],  # History
             "D",
             2,
             3,
             2,
             2,
            ];

my $MAX = 5;
my $root = [ { },
             [],
             "A",
             undef,
             "X",
             1,
             11,  # increase
             8,
             3,
            ];

sub children {
  my ($node) = @_;
  my ($met, $cur_seating, $next_person,
      $history, $last_person, $seating_number, $target_seatings, $n_tables,
      $people_per_table) = @$node;

  return if $seating_number > $target_seatings;
  if ($next_person gt $last_person) { # finished complete seating; start next
    return [ $met,
             [],
             "A",
             [ $cur_seating, $history ],
             $last_person,
             $seating_number + 1,
             $target_seatings,
             $n_tables,
             $people_per_table,
            ];
  }

  my $next_next_person = chr(1+ord($next_person));
  my @children;
  # try to seat $next_person at one of the tables we have already
  for my $table_i (0 .. $#{$cur_seating}) {
    my $table = $cur_seating->[$table_i];
    next if @$table == $people_per_table;
    if (can_seat($met, $next_person, $table)) {
      my %new_met = %$met;
      for my $person (@$table) { $new_met{"$person,$next_person"} = $new_met{"$next_person,$person"} = 1 }
      my @new_seating = @$cur_seating;
      @new_seating[$table_i] = [ @$table, $next_person ];
      push @children,
        [ \%new_met,
          \@new_seating,
          $next_next_person,
          $history,
          $last_person,
          $seating_number,
          $target_seatings,
          $n_tables,
          $people_per_table,
         ],
    }
  }

  # try to seat $next_person at a new table
  if (@$cur_seating < $n_tables) {
    push @children,
      [ $met,
        [ @$cur_seating, [ $next_person ] ],
        $next_next_person,
        $history,
        $last_person,
        $seating_number,
        $target_seatings,
        $n_tables,
        $people_per_table,
       ];
  }

  return @children;
}

sub can_seat {
  my ($met, $next_person, $table) = @_;
  for my $person (@$table) {
    return if $met->{"$person,$next_person"};
  }
  return 1;
}

sub winner {
  my ($node) = @_;
  if (@{$node->[1]} == 0 && $node->[5] > $MAX) {
    $MAX = $node->[5];
    return 1;
  }
  return ;
#  $node->[5] > $node->[6];   # current seating number > $target number of seatings
}

sub to_str {
  my ($node) = @_;
  my $s = "";
  if (@{$node->[1]}) { $s = "current seating: " . seating_to_str($node->[1]) . "\n" }
  my $history = $node->[3];
  while ($history) {
    $s .= "  " . seating_to_str($history->[0]) . "\n";
    $history = $history->[1];
  }
  return $s;
}

sub seating_to_str {
  my ($seating) = @_;
  my @s = map {join "", @$_ } @$seating;
  return join " " => @s;
}

# Typical node:
# [ target sum, used, remaining pool ]
my $S = Searcher->new({ children => \&children,
                        winner => \&winner,
                        to_str => \&to_str,
                       });

my $search = Search->new_search($S, [$root], { DFS => 1, trace => 100000 });

while (my $win = $search->next ) {
  print "NEW WINNER!!\n";
  print "MAX=$MAX\n", to_str($win), "\n\n";
  last if $MAX == 12;
}
