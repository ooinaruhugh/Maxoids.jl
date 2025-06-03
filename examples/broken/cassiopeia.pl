#!/usr/bin/env perl

use Modern::Perl 2018;
use CInet::Base;
use CInet::Propositional;
use Path::Tiny;
use bignum lib => 'GMP';
use List::Util qw(reduce);

sub to_binary   { 0+ "0b@{[ shift ]}" }
sub to_binstr   { sprintf("%0*s", 0+ Cube(4)->squares, shift->to_bin) }
sub to_relation { CIR(4 => to_binstr shift) }

sub intersect { reduce { $a | $b } 0, @_ }
sub is_subset { ($_[0] | $_[1]) == $_[0] }

my $cass = CIR(5 => '1' x Cube(5)->squares);
$cass->cival([[1,4],[3,5],[2]]) = 0;
$cass->cival([[1],[2,3,5],[]]) = 0;
$cass->cival([[1,2,4],[3],[]]) = 0;
$cass->cival([[1,3],[2],[]]) = 0;
$cass = Gaussoids->completion($cass);
$cass->cival([[1],[3],[4,5]]) = 0; # special for C^*

#say for $cass->minors(4)->list;
#for my $IK ($cass->cube->faces(4)) {
#    say FACE($IK), ': ', $cass->minor($IK);
#}

my $eg = $cass->minor([[1,2,3,4], [5]]);
# Get all supersets of $eg from alldis.txt
my $pat = "$eg" =~ s/1/./gr;
my @alldis = path('alldis.txt')->lines_utf8({ chomp => 1});
my @above = map { to_binary($_) } grep { $_ =~ qr/^$pat$/ } @alldis;

say "$eg => ", to_relation intersect @above;
