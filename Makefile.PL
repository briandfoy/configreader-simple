# $Id$
use strict;

use ExtUtils::MakeMaker;

sub ExtUtils::MM_Any::test_via_harness
	{
    my($self, $perl, $tests) = @_;

    return qq|\t$perl "-MTest::Manifest" | .
           qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
           qq|'\$(INST_ARCHLIB)')"\n|;
	}

WriteMakefile(
    'NAME'	       => 'ConfigReader::Simple',
	'VERSION_FROM' => 'lib/ConfigReader/Simple.pm',

	'PREREQ_PM'    => {
		'File::Find::Rule' => '0',
		'Test::Manifest'   => '0.9',
		'Test::More'       => '0',
		'Test::Pod'        => '0',
		'Test::Prereq'     => '0.14',
		},
		                      
    depend => { Makefile => 't/test_manifest' },
    clean  => { FILES => "ConfigReader-Simple-*" },

	);

1;
