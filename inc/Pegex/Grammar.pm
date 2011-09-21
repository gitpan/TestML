#line 1
##
# name:      Pegex::Grammar
# abstract:  Pegex Grammar Base Class
# author:    Ingy döt Net <ingy@cpan.org>
# license:   perl
# copyright: 2010, 2011

package Pegex::Grammar;
use Pegex::Mo;

# Grammar can be in text or tree form. Tree will be compiled from text.
has 'text' => default => sub {
    my $self = shift;
    die "Can't create a '" . ref($self) . "' grammar. No 'text' or 'tree'.";
};
has 'tree' => builder => 'tree_';
sub tree_ {
    require Pegex::Compiler;
    Pegex::Compiler->compile($_[0]->text)->tree;
}

# Parser and receiver classes to use.
has 'parser' => default => sub {'Pegex::Parser'};
has 'receiver' => default => sub {
    require Pegex::Receiver;
    Pegex::Receiver->new(wrap => 1);
};

sub parse {
    my $self = shift;
    $self = $self->new unless ref $self;

    die "Usage: " . ref($self) . '->parse($input [, $start_rule]'
        unless 1 <= @_ and @_ <= 2;

    my $parser = $self->parser;
    if (not ref $parser) {
        eval "require $parser";
        my $receiver = $self->receiver;
        $receiver = do {
            eval "require $receiver";
            $receiver->new;
        } unless ref $receiver;
        $parser = $parser->new(
            grammar => $self,
            receiver => $receiver,
        );
    }

    return $parser->parse(@_);
}

sub import {
    goto &Pegex::Mo::import
        unless ((caller))[1] =~ /^-e?$/ and @_ == 2 and $_[1] eq 'compile';
    my $package = shift;
    $package->compile_into_module();
    exit;
}

sub compile_into_module {
    my ($package) = @_;
    my $grammar = $package->text;
    my $module = $package;
    $module =~ s!::!/!g;
    $module = "$module.pm";
    my $file = $INC{$module} or return;
    require Pegex::Compiler;
    my $perl = Pegex::Compiler->compile($grammar)->to_perl;
    open IN, $file or die $!;
    my $module_text = do {local $/; <IN>};
    close IN;
    $perl =~ s/^/  /gm;
    $module_text =~ s/^(sub\s+tree_?\s*\{).*?(^\})/$1\n$perl$2/ms;
    open OUT, '>', $file or die $!;
    print OUT $module_text;
    close OUT;
}


1;

