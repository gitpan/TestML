package TestML::Library;
$TestML::Library::VERSION = '0.34';
use TestML::Base;

sub runtime {
    $TestML::Runtime::Singleton;
}

1;
