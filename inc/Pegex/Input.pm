#line 1
##
# name:      Pegex::Input
# abstract:  Pegex Parser Input Abstraction
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2011

package Pegex::Input;
use Pegex::Mo;

has 'string';
has 'stringref';
has 'file';
has 'handle';
# has 'http';
has '_buffer' => default => sub { my $x; \$x };
has '_is_eof' => default => sub { 0 };
has '_is_open' => default => sub { 0 };
has '_is_close' => default => sub { 0 };
# has '_pos' => 0;
# has 'maxsize' => 4096;
# has 'minlines' => 2;

sub new {
    my $class = shift;
    die "Pegex::Input->new() requires one or 2 arguments"
        unless 1 <= @_ and @_ <= 2;
    my $method = @_ == 2 ? shift : $class->_guess_input(@_);
    return $class->SUPER::new($method => shift);
}

# NOTE: Current implementation reads entire input into _buffer on open().
sub read {
    my ($self) = @_;
    die "Attempted Pegex::Input::read before open" if not $self->_is_open;
    die "Attempted Pegex::Input::read after EOF" if $self->_is_eof;
    
    my $buffer = $self->_buffer;
    $self->_buffer(undef);
    $self->_is_eof(1);

    return $$buffer;
}

sub open {
    my $self = shift;
    die "Pegex::Input::open takes no arguments" if @_;
    die "Attempted to reopen Pegex::Input object"
        if $self->_is_open or $self->_is_close;

    if (my $ref = $self->stringref) {
        $self->_buffer($ref);
    }
    elsif (my $handle = $self->handle) {
        $self->_buffer(\ do { local $/; <$handle> });
    }
    elsif (my $path = $self->file) {
        open my $handle, $path
            or die "Pegex::Input can't open $path for input:\n$!";
        $self->_buffer(\ do { local $/; <$handle> });
    }
    elsif (exists $self->{string}) {
        $self->_buffer(\$self->{string});
    }
    else {
        die "Pegex::open failed. No source to open";
    }

    $self->_is_open(1);

    return $self;
}

sub close {
    my ($self) = @_;
    die "Attempted to close an unopen Pegex::Input object" if $self->_is_close;
    close $self->handle if $self->handle;
    $self->_is_open(0);
    $self->_is_close(1);
    $self->_buffer(undef);
    return $self;
}

sub _guess_input {
    return ref($_[1])
        ? (ref($_[1]) eq 'SCALAR')
            ? 'stringref'
            : 'handle'
        : (length($_[1]) and ($_[1] !~ /\n/) and -f $_[1])
            ? 'file'
            : 'string';
}

1;

