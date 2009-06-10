use 5.006;

use strict;

use ExtUtils::MakeMaker;

eval "use Test::Manifest 1.21";
	
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

	(
	$ExtUtils::MakeMaker::VERSION ge '6.48' ? 
		(
		MIN_PERL_VERSION => 5.006,

		META_MERGE       => {
			resources => {
		  		repository => 'git://github.com/briandfoy/test-output.git',
				},
			keywords => ['testing','STDOUT','STDERR'],
	  		},
	 	) 
	 	: 
	 	()
	 ),
		                      
	'MAN3PODS' => {
		'lib/Simple.pm' => 
			'$(INST_MAN3DIR)/ConfigReader::Simple.$(MAN3EXT)',
		},

    clean  => { FILES => "ConfigReader-Simple-*" },

	);
