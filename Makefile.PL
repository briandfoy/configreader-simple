# $Id$
use strict;

use ExtUtils::MakeMaker;

eval "use Test::Manifest";

unless( $@ )
	{
	*ExtUtils::MM_Any::test_via_harness = sub
		{
		my($self, $perl, $tests) = @_;
	
		return qq|\t$perl "-MTest::Manifest" | .
			   qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			   qq|'\$(INST_ARCHLIB)')"\n|;
		}
	}
	
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
