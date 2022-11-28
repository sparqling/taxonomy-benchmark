#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM nodes.dmp names.dmp
";

my %OPT;
getopts('n', \%OPT);
if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my ($NODES, $NAMES) = @ARGV;

my %NAMES = ();
my %SCIENTIFIC_NAME = ();
open(NAMES, $NAMES) || die;
my %PREDICATE = ();
my %CLASS = ();
while (<NAMES>) {
    chomp;
    if (/\t\|$/) {
        s/\t\|$//;
        my @x = split(/\t\|\t/, $_, -1);
        if (@x == 4) {
            my $taxid = $x[0];
            my $name = $x[1];
            my $class = $x[3];
            check_if_number($taxid);
            $name = escape_string($name);
            my $predicate = makePredicate($class);
            $CLASS{$class}++;
            $PREDICATE{$predicate}++;
            if ($class eq "scientific name") {
                if ($SCIENTIFIC_NAME{$taxid}) {
                    die;
                } else {
                    $SCIENTIFIC_NAME{$taxid} = $name;
                }
            } else {
                if ($NAMES{$taxid}{$predicate}) {
                    $NAMES{$taxid}{$predicate} .= ", $name";
                } else {
                    $NAMES{$taxid}{$predicate} = "        :$predicate $name";
                }
            }
        } else {
            die;
        }
    } else {
        die;
    }
}
close(NAMES) || die;

# print STDERR scalar(keys %CLASS), " classes\n";
# print STDERR scalar(keys %PREDICATE), " predicates\n";
# print STDERR scalar(keys %SCIENTIFIC_NAME), " scientific names\n";
# print STDERR scalar(keys %NAMES), " names\n";

# for my $class (sort {$CLASS{$b} <=> $CLASS{$a}} keys %CLASS) {
#     print STDERR "$class\t$CLASS{$class}\n";
# }

# for my $predicate (sort {$PREDICATE{$b} <=> $PREDICATE{$a}} keys %PREDICATE) {
#     print STDERR "$predicate\t$PREDICATE{$predicate}\n";
# }

# for my $taxid (sort keys %SCIENTIFIC_NAME) {
#     if ($SCIENTIFIC_NAME{$taxid} =~ /,/) {
#         print STDERR "$SCIENTIFIC_NAME{$taxid}\n";
#     }
# }

if ($OPT{n}) {
    print "taxid,rank,name\n";
} else {
    print "taxid1,taxid2,name\n";
}
open(NODES, $NODES) || die;
while (<NODES>) {
    chomp;
    if (/\t\|$/) {
        s/\t\|$//;
        my @x = split(/\t\|\t/, $_, -1);
        if (@x == 13) {
            my $taxid = $x[0];
            my $parent = $x[1];
            my $rank = $x[2];
            check_if_number($taxid);
            check_if_number($parent);
            my $rank_uc = capitalize($rank);
            my $scientific_name = $SCIENTIFIC_NAME{$taxid} || die;
            # print "\n";
            # print "taxid:$taxid a :Taxon ;\n";
            # print "        :rank :$rank_uc ;\n";
            # print $scientific_name;
            # for my $predicate (keys %{$NAMES{$taxid}}) {
            #     print $NAMES{$taxid}{$predicate}, " ;\n";
            # }
            # print "        rdfs:subClassOf taxid:$parent .\n";
            if ($OPT{n}) {
                print "$taxid,$rank_uc,$scientific_name\n";
            } else {
                print "$taxid,$parent,subClassOf\n";
            }
        } else {
            die;
        }
    } else {
        die;
    }
}
close(NODES) || die;

################################################################################
### Functions ##################################################################
################################################################################
sub check_if_number {
    my ($taxid) = @_;

    if ($taxid =~ /^\d+$/) {
        return;
    } else {
        die;
    }
}

sub capitalize {
    my ($str) = @_;

    if ($str =~ /^\s*$/) {
        die;
    }
    
    my @x = split(/ /, $str);

    my $out = "";
    for my $x (@x) {
        $out .= ucfirst($x);
    }
    
    return $out;
}

sub makePredicate {
    my ($str) = @_;

    if ($str =~ /^\s*$/) {
        die;
    }
    
    my @x = split(/[- ]/, $str);

    my $out = "";
    for (my $i=0; $i<@x; $i++) {
        if ($i) {
            $out .= ucfirst($x[$i]);
        } else {
            $out .= $x[$i];
        }
    }
    
    return $out;
}

sub escape_string {
    my ($str) = @_;

    $str =~ s/"/\\"/g;

    return '"' . $str . '"';
}
