package ConfigReader::Simple;
#
# Simple interface to a configuration file
#
# ObLegalStuff:
#    Copyright (c) 2000 Bek Oberin. All rights reserved. This program is
#    free software; you can redistribute it and/or modify it under the
#    same terms as Perl itself.
# 
# Last updated by gossamer on Sat Aug 12 09:06:08 EST 2000
#

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw();
@EXPORT_OK = qw();

$VERSION = "0.9";

my $DEBUG = 0;

=head1 NAME

ConfigReader::Simple - Simple configuration file parser

=head1 SYNOPSIS

   use ConfigReader::Simple;

   $config = ConfigReader::Simple->new("configrc", [qw(Foo Bar Baz Quux)]);

   $config->parse();
   
   $config->get("Foo");
   

=head1 DESCRIPTION

   C<ConfigReader::Simple> reads and parses simple configuration files. It's
   designed to be smaller and simpler than the C<ConfigReader> module
   and is more suited to simple configuration files.

=cut

###################################################################
# Functions under here are member functions                       #
###################################################################

=head1 CONSTRUCTOR

=item new ( FILENAME, DIRECTIVES )

This is the constructor for a new ConfigReader::Simple object.

C<FILENAME> tells the instance where to look for the configuration
file.

C<DIRECTIVES> is an optional argument and is a reference to an array.  
Each member of the array should contain one valid directive. A directive
is the name of a key that must occur in the configuration file. If it
is not found, the module will die. The directive list may contain all
the keys in the configuration file, a sub set of keys or no keys at all.

=cut

sub new {
   my $prototype = shift;
   my $filename = shift;
   my $keyref = shift;

   my $class = ref($prototype) || $prototype;
   my $self  = {};

   $self->{"filename"} = $filename;
   $self->{"validkeys"} = $keyref;

   bless($self, $class);
   return $self;
}


#
# destructor
#
sub DESTROY {
   my $self = shift;

   return 1;
}

=pod
=item parse ()

This does the actual work.  No parameters needed.

=cut

sub parse {
   my $self = shift;

   open(CONFIG, $self->{"filename"}) || 
      die "Config: Can't open config file " . $self->{"filename"} . ": $!";

   while (<CONFIG>) {
      chomp;

      next if /^\s*$/;  # blank
      next if /^\s*#/;  # comment

      my ($key, $value) = &parse_line($_);
      warn "Key:  '$key'   Value:  '$value'\n" if $DEBUG;
      
      $self->{"config_data"}{$key} = $value;
   }
   close(CONFIG);
   
 	$self->_validate_keys;

   return 1;

}

=pod
=item get ( DIRECTIVE )

Returns the parsed value for that directive.

=cut

sub get {
   my $self = shift;
   my $key = shift;

   return $self->{"config_data"}{$key};
}

# Internal methods

sub parse_line {
   my $text = shift;

   my ($key, $value);

   if ($text =~ /^\s*(\w+)\s+(['"]?)(.*?)\2\s*$/) {
      $key = $1;
      $value = $3;
   } else {
      die "Config: Can't parse line: $text\n";
   }

   return ($key, $value);
}


=pod

=item _validate_keys ( )

If any keys were declared when the object was constructed,
check that those keys actually occur in the configuration file.

=cut


sub _validate_keys {
	
   my $self = shift;
   
	if ( $self->{"validkeys"} )
	{
		my ($declared_key);
		my $declared_keys_ref = $self->{"validkeys"};
      foreach $declared_key ( @$declared_keys_ref )
      {
      	unless ( $self->{"config_data"}{$declared_key} )
      	{
         	die "Config: key '$declared_key' does not occur in file $self->{filename}\n";
      	}
         warn "Key: $declared_key found.\n" if $DEBUG;
      }
	}

   return 1;
}

=pod

=head1 LIMITATIONS/BUGS

Directives are case-sensitive.

If a directive is repeated, the first instance will silently be
ignored.

Always die()s on errors instead of reporting them.

C<get()> doesn't warn if used before C<parse()>.

C<get()> doesn't warn if you try to acces the value of an
unknown directive not know (ie: one that wasn't passed via C<new()>).

All these will be addressed in future releases.

=head1 CREDITS

Kim Ryan <kimaryan@ozemail.com.au> adapted the module to make declaring
keys optional.  Thanks Kim.

=head1 AUTHORS

Bek Oberin <gossamer@tertius.net.au>

=head1 COPYRIGHT

Copyright (c) 2000 Bek Oberin.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#
# End code.
#
1;
