#
# Skeleton Perl Makefile
#
# Last updated by gossamer on Wed Sep  2 13:52:39 EST 1998
#

require 5;
use strict;

use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'	   => 'ConfigReader::Simple',
    'VERSION_FROM' => 'lib/ConfigReader/Simple.pm',

    'dist'         => { 
                         COMPRESS => 'gzip -9f',
                         SUFFIX => '.gz',
                      },
);

sub MY::postamble {
   package MY;

   '

WEBDIR = /home/gossamer/web/netizen/homepage/code
WEB_FILELIST = $(WEBDIR)/file-list

webdist: dist
	@$(MKPATH) $(WEBDIR)/$(DISTNAME)/
	cp $(DISTVNAME).tar$(SUFFIX) $(WEBDIR)/$(DISTNAME)/
	cp README $(WEBDIR)/$(DISTNAME)/$(DISTVNAME).README

'
}

