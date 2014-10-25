package TestML;
use strict;
use warnings;
use 5.006001;

use TestML::Runtime;

$TestML::VERSION = '0.21';

our @EXPORT = qw(str num bool list WWW XXX YYY ZZZ);

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

    if (@_ > 1 and $_[1] eq '-base') {
        goto &TestML::Base::import;
    }

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

    require Exporter;
    @_ = ($pkg);
    goto &Exporter::import;
}

1;

=encoding utf-8

=head1 NAME

TestML - A Generic Software Testing Meta Language

=head1 SYNOPSIS

    # file t/testml/encode.tml
    %TestML 1.0

    Title = 'Tests for AcmeEncode';
    Plan = 3;

    *text.apply_rot13 == *rot13;
    *text.apply_md5   == *md5;

    === Encode some poetry
    --- text
    There once was a fellow named Ingy,
    Combining languages twas his Thingy.
    --- rot13
    Gurer bapr jnf n sryybj anzrq Vatl,
    Pbzovavat ynathntrf gjnf uvf Guvatl.
    --- md5: 7a1538ff9fc8edf8ea55d02d0b0658be

    === Encode a password
    --- text: soopersekrit
    --- md5: 64002c26dcc62c1d6d0f1cb908de1435

This TestML document defines 2 assertions, and defines 2 data blocks.
The first block has 3 data points, but the second one has only 2.
Therefore the rot13 assertion applies only to the first block, while the
the md5 assertion applies to both. This results in a total of 3 tests,
which is specified in the meta Plan statement in the document.

To run this test you would have a normal test file that looks like this:

    use TestML::Runtime::TAP;

    TestML::Runtime::TAP->new(
        testml => 'testml/encode.tml',
        bridge => 't::Bridge',
    )->run();

or more simply:

    use TestML -run,
        -testml => 'testml/encode.tml',
        -bridge => 't::Bridge';

The apply_* transform functions are defined in the bridge class that is
specified outside this test (t/Bridge.pm).

=head1 DESCRIPTION

TestML is a generic, programming language agnostic, meta language for
writing unit tests. The idea is that you can use the same test files in
multiple implementations of a given programming idea. Then you can be
more certain that your application written in, say, Python matches your
Perl implementation.

In a nutshell you write a bunch of data tests that have inputs and
expected results. Using a simple syntax, you specify what functions the
data must pass through to produce the expected results. You use a bridge
class to write the data transform functions that pass the data through
your application.

In Perl 5, TestML is the evolution of the L<Test::Base> module. It has a
superset of Test:Base's goals. The data markup syntax is currently
exactly the same as Test::Base.

=head1 RESOURCES

Web: L<http://www.testml.org/>

CPAN: L<http://search.cpan.org/dist/TestML/>

GitHub: L<http://github.com/ingydotnet/testml-pm>

IRC: #testml on irc.freenode.net

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2009, 2010. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
