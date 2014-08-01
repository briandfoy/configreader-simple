use 5.006;

use strict;

use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.21";
	
WriteMakefile(
    'NAME'	        => 'ConfigReader::Simple',
    'VERSION_FROM'  => 'lib/ConfigReader/Simple.pm',
	'ABSTRACT'      => 'Simple configuration file parser',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	
    'PREREQ_PM'	    => {
		'Test::Warn'       => '0',
		'Test::Output'     => '0',
		},

	(
	$ExtUtils::MakeMaker::VERSION ge '6.48' ? 
		(
		MIN_PERL_VERSION => 5.006,

		META_MERGE       => {
			resources => {
		  		repository => 'https://github.com/briandfoy/ConfigReader-Simple',
				},
			keywords => ['config'],
	  		},
	 	) 
	 	: 
	 	()
	 ),

    clean  => { FILES => "ConfigReader-Simple-*" },
	);
