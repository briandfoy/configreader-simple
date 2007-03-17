#!/usr/bin/perl

use Test::More 'no_plan';

use_ok( "ConfigReader::Simple" );

#$ConfigReader::Simple::DEBUG = 1;

my $string = <<"HERE";
cat Buster
dog \\
	Tuffy
bird Poppy
HERE

my $config = ConfigReader::Simple->new();

$config->parse_string( \$string );

is( $config->get( "cat" ), "Buster" );
is( $config->get( "dog" ), "Tuffy" );
is( $config->get( "bird" ), "Poppy" );

