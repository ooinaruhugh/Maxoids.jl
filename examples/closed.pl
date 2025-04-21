#!/usr/bin/env perl

use Modern::Perl 2018;
use CInet::Base;

my $n = shift // die 'need ground set size';

my %seen;
my @all;
for (<<>>) {
    chomp;
    my $A = CIR($n => $_);
    push @all, $A;
    $seen{"$A"}++;
}
say 0+ keys %seen;

# First make sure that the input file was closed under permutations.
for my $A (@all) {
    for my $Ag ($A->orbit(SymmetricGroup)) {
        #die "not closed under permutations for $A"
        #    unless $seen{"$Ag"};
        $seen{"$Ag"}++;
    }
}
say 0+ keys %seen;

# Now check for duals.
for my $A (@all) {
    die "not closed under duality for $A"
        unless $seen{"". $A->dual};
}
