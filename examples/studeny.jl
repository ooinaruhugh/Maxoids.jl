# Test all implications for representability of 4-maxoids
# by discrete random variables. Notation follows:
#
# M. Studený: Conditional Independence Structures Over Four Discrete Random
# Variables Revisited: Conditional Ingleton Inequalities. IEEE Transactions
# on Information Theory, 67:11, 2021.

# E:1
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"14|2" ] => [ CI"12|4" ])
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"14|2" ] => [ CI"13|2" ])
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"14|2" ] => [ CI"14|3" ])
maxoid_implication(4, [ CI"12|4", CI"13|2", CI"14|3" ] => [ CI"12|3" ])
maxoid_implication(4, [ CI"12|4", CI"13|2", CI"14|3" ] => [ CI"13|4" ])
maxoid_implication(4, [ CI"12|4", CI"13|2", CI"14|3" ] => [ CI"14|2" ])
# E:2
maxoid_implication(4, [ CI"12|3", CI"14|2", CI"23|4", CI"34|1" ] => [ CI"12|4" ])
maxoid_implication(4, [ CI"12|3", CI"14|2", CI"23|4", CI"34|1" ] => [ CI"14|3" ])
maxoid_implication(4, [ CI"12|3", CI"14|2", CI"23|4", CI"34|1" ] => [ CI"23|1" ])
maxoid_implication(4, [ CI"12|3", CI"14|2", CI"23|4", CI"34|1" ] => [ CI"34|2" ])
maxoid_implication(4, [ CI"12|4", CI"14|3", CI"23|1", CI"34|2" ] => [ CI"12|3" ])
maxoid_implication(4, [ CI"12|4", CI"14|3", CI"23|1", CI"34|2" ] => [ CI"14|2" ])
maxoid_implication(4, [ CI"12|4", CI"14|3", CI"23|1", CI"34|2" ] => [ CI"23|4" ])
maxoid_implication(4, [ CI"12|4", CI"14|3", CI"23|1", CI"34|2" ] => [ CI"34|1" ])
# E:3
maxoid_implication(4, [ CI"12|34", CI"13|", CI"24|", CI"34|12" ] => [ CI"12|" ])
maxoid_implication(4, [ CI"12|34", CI"13|", CI"24|", CI"34|12" ] => [ CI"13|24" ])
maxoid_implication(4, [ CI"12|34", CI"13|", CI"24|", CI"34|12" ] => [ CI"24|13" ])
maxoid_implication(4, [ CI"12|34", CI"13|", CI"24|", CI"34|12" ] => [ CI"34|" ])
maxoid_implication(4, [ CI"12|", CI"13|24", CI"24|13", CI"34|" ] => [ CI"12|34" ])
maxoid_implication(4, [ CI"12|", CI"13|24", CI"24|13", CI"34|" ] => [ CI"13|" ])
maxoid_implication(4, [ CI"12|", CI"13|24", CI"24|13", CI"34|" ] => [ CI"24|" ])
maxoid_implication(4, [ CI"12|", CI"13|24", CI"24|13", CI"34|" ] => [ CI"34|12" ])
# E:4
maxoid_implication(4, [ CI"12|", CI"12|34", CI"34|1", CI"34|2" ] => [ CI"12|3" ])
maxoid_implication(4, [ CI"12|", CI"12|34", CI"34|1", CI"34|2" ] => [ CI"12|4" ])
maxoid_implication(4, [ CI"12|", CI"12|34", CI"34|1", CI"34|2" ] => [ CI"34|" ])
maxoid_implication(4, [ CI"12|", CI"12|34", CI"34|1", CI"34|2" ] => [ CI"34|12" ])
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"34|", CI"34|12" ] => [ CI"12|" ])
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"34|", CI"34|12" ] => [ CI"12|34" ])
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"34|", CI"34|12" ] => [ CI"34|1" ])
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"34|", CI"34|12" ] => [ CI"34|2" ])
# E:5
maxoid_implication(4, [ CI"12|34", CI"14|2", CI"23|", CI"34|1" ] => [ CI"12|4" ])
maxoid_implication(4, [ CI"12|34", CI"14|2", CI"23|", CI"34|1" ] => [ CI"14|23" ])
maxoid_implication(4, [ CI"12|34", CI"14|2", CI"23|", CI"34|1" ] => [ CI"23|1" ])
maxoid_implication(4, [ CI"12|34", CI"14|2", CI"23|", CI"34|1" ] => [ CI"34|" ])
maxoid_implication(4, [ CI"12|4", CI"14|23", CI"23|1", CI"34|" ] => [ CI"12|34" ])
maxoid_implication(4, [ CI"12|4", CI"14|23", CI"23|1", CI"34|" ] => [ CI"14|2" ])
maxoid_implication(4, [ CI"12|4", CI"14|23", CI"23|1", CI"34|" ] => [ CI"23|" ])
maxoid_implication(4, [ CI"12|4", CI"14|23", CI"23|1", CI"34|" ] => [ CI"34|1" ])

# I:1
maxoid_implication(4, [ CI"12|", CI"12|3", CI"34|1", CI"34|2" ] => [ CI"34|" ])
# I:2
maxoid_implication(4, [ CI"12|", CI"13|4", CI"34|1", CI"34|2" ] => [ CI"13|" ])
maxoid_implication(4, [ CI"12|", CI"13|4", CI"34|1", CI"34|2" ] => [ CI"34|" ])
# I:3
maxoid_implication(4, [ CI"12|", CI"12|4", CI"13|4", CI"34|2" ] => [ CI"13|" ])
# I:4
maxoid_implication(4, [ CI"12|", CI"13|4", CI"14|3", CI"34|2" ] => [ CI"13|" ])
maxoid_implication(4, [ CI"12|", CI"13|4", CI"14|3", CI"34|2" ] => [ CI"14|" ])
# I:5
maxoid_implication(4, [ CI"12|", CI"13|4", CI"24|3", CI"34|2" ] => [ CI"13|" ])
# I:6
maxoid_implication(4, [ CI"12|", CI"13|4", CI"23|4", CI"34|2" ] => [ CI"13|" ])
# I:7
maxoid_implication(4, [ CI"12|", CI"12|3", CI"13|4", CI"34|2" ] => [ CI"12|" ])
maxoid_implication(4, [ CI"12|", CI"12|3", CI"13|4", CI"34|2" ] => [ CI"13|" ])
# I:8
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"24|3", CI"34|2" ] => [ CI"13|2" ])
# I:9
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"13|4", CI"34|2" ] => [ CI"13|2" ])
# I:10
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"14|3", CI"34|2" ] => [ CI"13|2" ])
# I:11
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"34|1", CI"34|2" ] => [ CI"13|2" ])
# I:12
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"23|4", CI"34|2" ] => [ CI"13|2" ])
# I:13
maxoid_implication(4, [ CI"12|", CI"12|3", CI"12|4", CI"34|12" ] => [ CI"12|34" ])
# I:14
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"13|4", CI"34|12" ] => [ CI"12|4" ])
maxoid_implication(4, [ CI"12|3", CI"12|4", CI"13|4", CI"34|12" ] => [ CI"13|4" ])
# I:15
maxoid_implication(4, [ CI"12|", CI"12|3", CI"13|4", CI"34|12" ] => [ CI"13|24" ])
# I:16
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"24|3", CI"34|12" ] => [ CI"13|24" ])
# I:17
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"14|3", CI"34|12" ] => [ CI"13|24" ])
# I:18
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"34|1", CI"34|12" ] => [ CI"13|24" ])
# I:19
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"23|4", CI"34|12" ] => [ CI"13|4" ])
maxoid_implication(4, [ CI"12|3", CI"13|4", CI"23|4", CI"34|12" ] => [ CI"23|4" ])
