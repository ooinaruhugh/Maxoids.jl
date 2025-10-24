#!/usr/bin/env perl

use Modern::Perl 2018;
use CInet::Base;

my $n = shift // die 'need ground set size';
my $seq = CInet::Seq::List->new(
    map { chomp; CIR($n => $_) } <<>>
) -> modulo(SymmetricGroup)
  -> map(sub{ $_->representative(SymmetricGroup) })
  -> sort(with => sub{
    (0+ $a->independences <=> 0+ $b->independences) ||
    ("$a" cmp "$b")
});

for my $A ($seq->list) {
    say '{ ', join(", ", map { '[' . FACE . ']' } $A->independences), ' }';
}
