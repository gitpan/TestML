use lib 't';
use TestML;
use TestMLBridge;

TestML->new(
    testml => 'testml/semicolons2.tml',
    bridge => 'TestMLBridge',
)->run;
