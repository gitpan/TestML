#line 1
package TestML::Library::Debug;
use TestML();

sub WWW {
    require XXX;
    local $XXX::DumpModule = $TestML::DumpModule;
    XXX::WWW(shift->value);
}

sub XXX {
    require XXX;
    local $XXX::DumpModule = $TestML::DumpModule;
    XXX::XXX(shift->value);
}

sub YYY {
    require XXX;
    local $XXX::DumpModule = $TestML::DumpModule;
    XXX::YYY(shift->value);
}

sub ZZZ {
    require XXX;
    local $XXX::DumpModule = $TestML::DumpModule;
    XXX::ZZZ(shift->value);
}

1;
