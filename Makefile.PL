# $Id$
use strict;

use ExtUtils::MakeMaker;

my $tests = do {
        local @ARGV = qw(t/test_manifest);
        my $data = join " ", map {chomp; "t/$_" } <>;
        };

WriteMakefile(
    'NAME'	       => 'ConfigReader::Simple',
	'VERSION_FROM' => 'lib/ConfigReader/Simple.pm',

	'PREREQ_PM'    => {
		'File::Find::Rule' => '0',
		'Test::More'       => '0',
		'Test::Pod'        => '0',
		'Test::Prereq'     => '0',
		},
		
    'dist'         => { 
                         COMPRESS => 'gzip -9f',
                         SUFFIX => '.gz',
                      },
                      
    depend => { Makefile => 't/test_manifest' },
    test   => { TESTS => $tests },

);

1;
