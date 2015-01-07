use 5.008;
use strict;
use warnings;
	
my $github    = 'https://github.com/briandfoy/';
my $main_file = 'lib/ConfigReader/Simple.pm';

my %WriteMakefile = (
	MIN_PERL_VERSION => 5.008,

    'NAME'	        => 'ConfigReader::Simple',
    'VERSION_FROM'  => $main_file,
	'ABSTRACT_FROM' => $main_file,
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',
	
    'PREREQ_PM'	    => {
		'Test::Warn'       => '0',
		'Test::Output'     => '0',
		},

	(
	$ExtUtils::MakeMaker::VERSION ge '6.48' ? 
		(

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

sub arguments { \%WriteMakefile }

do_it() unless caller;
sub do_it {
	require File::Spec;
	my $MM ='ExtUtils::MakeMaker';
	my $MM_version =
		eval{ "$MM " . $WriteMakefile{'CONFIGURE_REQUIRES'}{'ExtUtils::MakeMaker'} }
			//
		"$MM 6.64";
	eval "use $MM_version" || die "Could not load $MM_version: $@";
	eval "use Test::Manifest 1.21" 
		if -e File::Spec->catfile( qw(t test_manifest) );
	WriteMakefile( %WriteMakefile );
	}


no warnings;
__PACKAGE__;
