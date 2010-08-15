#line 1
package Module::Install::Gloom;
use strict;
use warnings;

use Module::Install::Base;

use vars qw(@ISA);
BEGIN { @ISA = 'Module::Install::Base' }

sub use_gloom {
    my $self = shift;
    my $target = shift
        or die "use_gloom requires the name of a target module";
    $target =~ s/::/\//g;
    $target = "lib/$target.pm";
    my $gloom_path = $self->admin->find_in_inc('Gloom') or return;
    $self->admin->copy($gloom_path => $target);
}

1;

=encoding utf8

#line 68
