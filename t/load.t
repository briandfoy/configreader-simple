# $Id$

use Test::More tests => 1;
print "bail out! ConfigReader::Simple did not compile" 
	unless use_ok( 'ConfigReader::Simple' );

