package TestML;
use strict;
use warnings;
use 5.006001;

$TestML::VERSION = '0.04';

sub import {
    my $run;
    my $bridge = 'main';
    my $document;

    if ($_[1] eq '-base') {
        goto &TestML::Base::import;
    }

    my $pkg = shift;
    while (@_) {
        my $option = shift(@_);
        my $value = (@_ and $_[0] !~ /^-/) ? shift(@_) : '';
        if ($option eq '-run') {
            $run = $value || 'TestML::Runner::TAP';
        }
        elsif ($option eq '-document') {
            $document = $value;
        }
        elsif ($option eq '-bridge') {
            $bridge = $value;
        }
        else {
            die "Unknown option '$option'";
        }
    }

    sub END {
        no warnings;
        if ($run) {
            eval "require $run; 1" or die $@;
            $run->new(
                document => ($document || \ *main::DATA),
                bridge => $bridge,
            )->run();
        }
        elsif ($document or $bridge) {
            die "-document or -bridge option used without -run option\n";
        }
    }
}

1;

=encoding utf-8

=head1 NAME

TestML - A Generic Software Testing Meta Language

=head1 SYNOPSIS

    # file t/testml/encode.tml
    %TestML: 1.0

    %Title: Tests for AcmeEncode
    %Plan: 3

    *text.apply_rot13()  == *rot13;
    *text.apply_md5()    == *md5;

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

    use TestML::Runner::TAP;

    TestML::Runner::TAP->new(
        document => 'testml/encode.tml',
        bridge => 't::Bridge',
    )->run();

or more simply:

    use TestML -run,
        -document => 'testml/encode.tml',
        -bridge => 't::Bridge';

The apply_* functions are defined in the bridge class that is specified
outside this test (t/Bridge.pm).

=head1 DESCRIPTION

TestML is a generic, programming language agnostic, meta language for
writing unit tests. The idea is that you can use the same test files in
multiple implementations of a given programming idea. Then you can be
more certain that your application written in, say, Python matches your
Perl implementation.

In a nutshell you write a bunch of data tests that have inputs and
expected results. Using a simple syntax, you specify what functions the
data must pass through to produce the expected results. You use a bridge
class to write the functions that pass the data through your
application.

=head1 SEE ALSO

See L<http://www.testml.org/> for more information on TestML.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2009, 2010. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
