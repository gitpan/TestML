#line 1
##
# name:      TestML
# author:    Ingy döt Net <ingy@cpan.org>
# abstract:  A Generic Software Testing Meta Language
# license:   perl
# copyright: 2009, 2010, 2011
# see:
# - http://www.testml.org/
# - irc://irc.freenode.net#testml 

use 5.006001;
use strict;
use warnings;

my $requires = "
use Pegex 0.19 ();
";

package TestML;

use TestML::Runtime;

our $VERSION = '0.25';

use constant XXX_skip => 1;
our $DumpModule = 'YAML::XS';
sub WWW { require XXX; local $XXX::DumpModule = $DumpModule; XXX::WWW(@_) }
sub XXX { require XXX; local $XXX::DumpModule = $DumpModule; XXX::XXX(@_) }
sub YYY { require XXX; local $XXX::DumpModule = $DumpModule; XXX::YYY(@_) }
sub ZZZ { require XXX; local $XXX::DumpModule = $DumpModule; XXX::ZZZ(@_) }

sub str { TestML::Str->new(value => $_[0]) }
sub num { TestML::Num->new(value => $_[0]) }
sub bool { TestML::Bool->new(value => $_[0]) }
sub list { TestML::List->new(value => $_[0]) }

my $skipped;
sub import {
    my $run;
    my $bridge = '';
    my $testml;
    $skipped = 0;

    strict->import;
    warnings->import;

    my $pkg = shift;
    while (@_) {
        my $option = shift(@_);
        my $value = (@_ and $_[0] !~ /^-/) ? shift(@_) : '';
        if ($option eq '-run') {
            $run = $value || 'TestML::Runtime::TAP';
        }
        elsif ($option eq '-testml') {
            $testml = $value;
        }
        elsif ($option eq '-bridge') {
            $bridge = $value;
        }
        # XXX skip_all should call skip_all() from runner subclass
        elsif ($option eq '-dev_test') {
            if (-e 'inc' and not -e 'inc/.author') {
                skip_all('This is a developer test');
            }
        }
        elsif ($option eq '-skip_all') {
            my $reason = $value;
            die "-skip_all option requires a reason argument"
                unless $reason;
            skip_all($reason);
        }
        elsif ($option eq '-require_or_skip') {
            my $module = $value;
            die "-require_or_skip option requires a module argument"
                unless $module and $module !~ /^-/;
            eval "require $module; 1" or do {
                $skipped = 1;
                require Test::More;
                Test::More::plan(
                    skip_all => "$module failed to load"
                );
            } 
        }
        else {
            die "Unknown option '$option'";
        }
    }

    sub skip_all {
        return if $skipped;
        my $reason = shift;
        $skipped = 1;
        require Test::More;
        Test::More::plan(
            skip_all => $reason,
        );
    }

    sub END {
        no warnings;
        return if $skipped;
        if ($run) {
            eval "require $run; 1" or die $@;
            $bridge ||= 'main';
            $run->new(
                testml => ($testml || \ *main::DATA),
                bridge => $bridge,
            )->run();
        }
        elsif ($testml or $bridge) {
            die "-testml or -bridge option used without -run option\n";
        }
    }

    no strict 'refs';
    my $p = caller;
    *{$p.'::str'} = \&str;
    *{$p.'::num'} = \&num;
    *{$p.'::bool'} = \&bool;
    *{$p.'::list'} = \&list;

    if (not defined &{$pkg.'::XXX'}) {
        *{$p.'::WWW'} = \&WWW;
        *{$p.'::XXX'} = \&XXX;
        *{$p.'::YYY'} = \&YYY;
        *{$p.'::ZZZ'} = \&ZZZ;
    }
}

1;

