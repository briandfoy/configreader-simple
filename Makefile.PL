# $Id$
use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	        => 'ConfigReader::Simple',
    'VERSION_FROM'  => 'lib/ConfigReader/Simple.pm',

    'PREREQ_PM'	    => {
		'Test::More'       => '0',
		},
		                      
    clean  => { FILES => "ConfigReader-Simple-*" },

	);
