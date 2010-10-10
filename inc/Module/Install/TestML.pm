#line 1
package Module::Install::TestML;
use strict;
use warnings;

use Module::Install::Base;

use vars qw($VERSION @ISA);
BEGIN {
    $VERSION = '0.20';
    @ISA     = 'Module::Install::Base';
}

sub use_testml_tap {
    my $self = shift;

    $self->use_testml;
     
    $self->include('Test::More');
    $self->include('Test::Builder');
    $self->include('Test::Builder::Module');
    $self->requires('Filter::Util::Call');
}

sub use_testml {
    my $self = shift;

    $self->include('Pegex::Grammar');
    $self->include('Pegex::Base');

    $self->include('TestML');
    $self->include('TestML::Base');
    $self->include('TestML::Compiler');
    $self->include('TestML::Grammar');
    $self->include('TestML::Library::Debug');
    $self->include('TestML::Library::Standard');
    $self->include('TestML::Runtime');
    $self->include('TestML::Runtime::TAP');
}

sub testml_setup {
    my $self = shift;
    return unless $self->is_admin;
    my $config = shift;
    die "setup_config requires a yaml file argument"
        unless $config;
    die "'$config' is not an existing file"
        unless -f $config;
    print "testml_setup\n";
    require TestML::Setup;
    TestML::Setup::testml_setup($config);
}

1;

=encoding utf8

#line 99
