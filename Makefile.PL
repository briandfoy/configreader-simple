# $Id$
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
