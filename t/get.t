# $Id$

use Test::More tests => 23;

use ConfigReader::Simple;
$loaded = 1;

my @Directives = qw( Test1 Test2 Test3 Test4 );
my $config = ConfigReader::Simple->new( "t/example.config", \@Directives );
isa_ok( $config, 'ConfigReader::Simple' );

# get things that do exist
is( $config->get( 'Test3' ), 'foo' );
is( $config->Test3, 'foo' );

is( $config->get( 'Test2' ), 'Test 2 value' );
is( $config->Test2, 'Test 2 value' );

# get things that do exist, but look like false values to perl
is( $config->get( 'Zero' ), '0' );
is( $config->get( 'Zero' ),  0  );
is( $config->get( 'Undef' ), '' );

# get things that do not exist
# using get
my $value = not defined $config->get( 'Test' );
ok( $value );
$value = not defined $config->Test;
ok( $value );

$value = not defined $config->get( 'Test5' );
ok( $value );
$value = not defined $config->Test5;
ok( $value );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # Now try it with multiple files
$config = ConfigReader::Simple->new_multiple( 
	Files => [ qw( t/global.config t/example.config ) ] );
isa_ok( $config, 'ConfigReader::Simple' );

# get things that do exist
is( $config->get( 'Test3' ), 'foo' );
is( $config->get( 'Scope' ), 'Global' );
is( $config->get( 'Test2' ), 'Test 2 value' );

# try it one at a time
$config = ConfigReader::Simple->new( "t/example.config" );

is( $config->get( 'Test3' ), 'foo' );
is( $config->get( 'Test2' ), 'Test 2 value' );

$config->add_config_file( "t/global.config" );
is( $config->get( 'Scope' ), 'Global' );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # Now try it with a string
my $string = <<'STRING';
TestA Lear
TestB MacBeth
TestC Richard
STRING

$config = ConfigReader::Simple->new_string(
	Strings => [ \$string ] );
isa_ok( $config, 'ConfigReader::Simple' );

is( $config->get( 'TestA' ), 'Lear' );
is( $config->get( 'TestB' ), 'MacBeth' );
is( $config->get( 'TestC' ), 'Richard' );


