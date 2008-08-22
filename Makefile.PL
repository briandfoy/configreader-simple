# $Id$
use strict;

require 5.006;

use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'	        => 'ConfigReader::Simple',
    'VERSION_FROM'  => 'lib/Simple.pm',
	'ABSTRACT'      => 'Simple configuration file parser',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	
    'PREREQ_PM'	    => {
		'Test::Warn'       => '0',
		'Test::Output'     => '0',
		},

	'PM'           => {
		'lib/Simple.pm'         => '$(INST_LIBDIR)/Simple.pm',
		},
		                      
	'MAN3PODS' => {
		'lib/Simple.pm' => 
			'$(INST_MAN3DIR)/ConfigReader::Simple.3',
		},

    clean  => { FILES => "ConfigReader-Simple-*" },

	);
