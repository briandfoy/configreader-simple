# $Id$
use strict;

use ExtUtils::MakeMaker;

eval "use Test::Pod";

if ( $@ || ($Test::Pod::VERSION <= '0.95') ) {
    warn "Test::Pod 0.95 is not installed, so we'll skip the POD tests.\n";
}

WriteMakefile(
    'NAME'	    => 'ConfigReader::Simple',
    'VERSION_FROM'  => 'lib/ConfigReader/Simple.pm',

    'PREREQ_PM'	    => {
		'Test::More'       => '0',
		},
		                      
    clean  => { FILES => "ConfigReader-Simple-*" },

);

1;
