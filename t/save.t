# $Id$

use Test::More tests => 18;
use Test::Warn;

use ConfigReader::Simple;

my @Directives = qw( Test1 Test2 Test3 Test4 );
my @Files      = map "t/$_.config", qw(save_test1 save_test2);

unlink @Files;

my $config = ConfigReader::Simple->new( "t/example.config", \@Directives );
isa_ok( $config, 'ConfigReader::Simple' );

########################################################################
# test with no values
{
my $result;

warning_like { $result = $config->save() } qr/No arguments to method/,
	'No arguments emits warning';

ok( ! defined $result, 'No arguments return undef' );
is( $@, '', 'There is nothing in $@ for a warning' );
}

########################################################################
# test with one value
{
ok( ! -e $Files[0], 'File does not exist' );
my $result = $config->save( $Files[0] );
ok( $result, 'Single argument returns true value' );
ok( -e $Files[0], 'File exists' );
}

########################################################################
# test with two values
foreach my $value ( undef, 'foo', {}, 0 )
	{
	my $result = eval { $config->save( $Files[0] => $value ) };
	ok( ! defined $result, 'Bad arguments return undef' );
	like( $@, qr/Argument is not an array reference/, 
		'Error string says the right thing' );
	}

########################################################################
# test with three values
{
my $result = eval { $config->save( $Files[0] => [], $Files[1] ) };
ok( ! defined $result, 'Three arguments return undef' );
like( $@, qr/Odd number of arguments/ );
}

########################################################################
# test with four values
{
my $result = eval { $config->save( 
	$Files[0] => [ qw( Test1 Test2 ) ], 
	$Files[1] => [ qw( Zero Test3 )  ]
	) };
ok( $result, 'Four arguments return true' );
}

unlink @Files;