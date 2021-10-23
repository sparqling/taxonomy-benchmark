#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM nodes.dmp names.dmp
";

my %OPT;
getopts('', \%OPT);
if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my ($NODES, $NAMES) = @ARGV;

my %NAMES = ();
my %SCIENTIFIC_NAME = ();
open(NAMES, $NAMES) || die;
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
            if ($class eq "scientific name") {
                if ($SCIENTIFIC_NAME{$taxid}) {
                    die;
                } else {
                    $SCIENTIFIC_NAME{$taxid} = "        :$predicate $name ;\n";
                }
            } else {
                if ($NAMES{$taxid}) {
                    $NAMES{$taxid} .= " ;\n";
                    $NAMES{$taxid} .= "        :$predicate $name";
                } else {
                    $NAMES{$taxid} = "        :$predicate $name";
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

print '@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .', "\n";
print '@prefix taxid: <http://identifiers.org/taxonomy/> .', "\n";
print '@prefix : <http://ddbj.nig.ac.jp/ontologies/taxonomy/> .', "\n";

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
            print "\n";
            print "taxid:$taxid a :Taxon ;\n";
            print "        :rank :$rank_uc ;\n";
            print $scientific_name;
            if ($NAMES{$taxid}) {
                print $NAMES{$taxid}, " ;\n";
            }
            print "        rdfs:subClassOf taxid:$parent .\n";
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
