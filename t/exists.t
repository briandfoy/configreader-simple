# $Id$

use Test::More tests => 17;

use ConfigReader::Simple;

my @Directives = qw( Test1 Test2 Test3 Test4 );

my $config = ConfigReader::Simple->new( "t/example.config", \@Directives );
isa_ok( $config, 'ConfigReader::Simple' );

# these directives should be okay
foreach my $directive ( @Directives )
	{
	ok( $config->exists( $directive ),
		"Directive [$directive] should exist, but I cannot tell it does" );
	}	

	
	
# these directives should not be okay
foreach my $directive ( qw(Test5 exists blah get) )
	{
	my $not_value = not $config->exists( $directive );
	ok( $not_value, "Directive [$directive] shouldn't exist, but I think it does" );

	my $value = $config->get( 'Test5' );
	$not_value = not $config->exists( $directive );
	ok( $not_value, "Directive [$directive] shouldn't exist, but I think it does" );
	
	$value = $config->Test5;
	$not_value = not $config->exists( $directive );
	ok( $not_value, "Directive [$directive] shouldn't exist, but I think it does" );
	}	
