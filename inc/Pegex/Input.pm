#line 1
##
# name:      Pegex::Input
# abstract:  Pegex Parser Input Abstraction
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011, 2012

package Pegex::Input;
use Pegex::Base;

has string => ();
has stringref => ();
has file => ();
has handle => ();
has _buffer => ();
has _is_eof => 0;
has _is_open => 0;
has _is_close => 0;

# NOTE: Current implementation reads entire input into _buffer on open().
sub read {
    my ($self) = @_;
    die "Attempted Pegex::Input::read before open" if not $self->{_is_open};
    die "Attempted Pegex::Input::read after EOF" if $self->{_is_eof};

    my $buffer = $self->{_buffer};
    $self->{_buffer} = undef;
    $self->{_is_eof} = 1;

    return $buffer;
}

sub open {
    my ($self) = @_;
    die "Attempted to reopen Pegex::Input object"
        if $self->{_is_open} or $self->{_is_close};

    if (my $ref = $self->{stringref}) {
        $self->{_buffer} = $ref;
    }
    elsif (my $handle = $self->{handle}) {
        $self->{_buffer} = \ do { local $/; <$handle> };
    }
    elsif (my $path = $self->{file}) {
        open my $handle, $path
            or die "Pegex::Input can't open $path for input:\n$!";
        $self->{_buffer} = \ do { local $/; <$handle> };
    }
    elsif (exists $self->{string}) {
        $self->{_buffer} = \$self->{string};
    }
    else {
        die "Pegex::open failed. No source to open";
    }
    $self->{_is_open} = 1;
    return $self;
}

sub close {
    my ($self) = @_;
    die "Attempted to close an unopen Pegex::Input object"
        if $self->{_is_close};
    close $self->{handle} if $self->{handle};
    $self->{_is_open} = 0;
    $self->{_is_close} = 1;
    $self->{_buffer} = undef;
    return $self;
}

sub _guess_input {
    my ($self, $input) = @_;
    return ref($input)
        ? (ref($input) eq 'SCALAR')
            ? 'stringref'
            : 'handle'
        : (length($input) and ($input !~ /\n/) and -f $input)
            ? 'file'
            : 'string';
}

1;

