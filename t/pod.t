# $Id$

BEGIN {
    @files = qw(
		lib/ConfigReader/Simple.pm
    	);
	}

use Test::More tests => scalar @files;

SKIP: {
    eval { use Test::Pod };

    skip "Test::Pod 0.95 not installed", scalar @files 
    	if $@ || $Test::Pod::VERSION <= '0.95';

    pod_file_ok("blib/$_") foreach @files;
	}

