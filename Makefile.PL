# $Id$
use strict;

use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'	        => 'ConfigReader::Simple',
    'VERSION_FROM'  => 'lib/ConfigReader/Simple.pm',

    'PREREQ_PM'	    => {
		'Test::More'       => '0',
		'Test::Warn'       => '0',
		},
		                      
	'MAN3PODS' => {
		'lib/ConfigReader/Simple.pm' => 
			'$(INST_MAN3DIR)/ConfigReader::Simple.3',
		},

    clean  => { FILES => "ConfigReader-Simple-*" },

	);
