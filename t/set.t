# $Id$

use Test::More tests => 11;

use ConfigReader::Simple;

my @Directives = qw( Test1 Test2 Test3 Test4 );
my $config = ConfigReader::Simple->new( "t/example.config", \@Directives );
isa_ok( $config, 'ConfigReader::Simple' );

# set things that do exist
foreach my $pair ( 
	[ qw(Test1 Foo)] , [ qw(Pagagena Papageno) ], [ qw(Tamino Pamina) ] )
	{
	my $key   = $pair->[0];
	my $value = $pair->[1];

	$config->set( $key, $value );

	is( $config->get( $key ), $value, 
		"$key has the right value with get" );
	is( $config->$key, $value,  
		"$key has the right value with autoload" );
	}
	
# unset things that do exist
{
my $directive = 'Test2';

ok( $config->unset( $directive ), "Unset thing that exists [$directive]" );

my $not_defined = not defined $config->$directive;

ok( $not_defined, "Unset thing [$directive] still has value" );
}

# unset things that do not exist
{
my $directive = 'Tenor';

my $value = not $config->unset( $directive );
ok( $value, 'Unset thing that does not exist [$directive]' );

$value = not $config->exists( $directive );
ok( $value, 'Unset thing that did not exist [$directive] exists' );
}
