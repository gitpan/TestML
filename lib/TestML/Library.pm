package TestML::Library;
$TestML::Library::VERSION = '0.32';
use TestML::Base;

sub runtime {
    $TestML::Runtime::Singleton;
}

1;
