package ConfigReader::Simple;
use strict;

# $Id$

use vars qw($VERSION $AUTOLOAD);

use Carp qw(croak);

( $VERSION ) = q$Revision$ =~ m/ (\d+ \. \d+) /gx;

my $DEBUG = 0;

=head1 NAME

ConfigReader::Simple - Simple configuration file parser

=head1 SYNOPSIS

   use ConfigReader::Simple;

   $config = ConfigReader::Simple->new("configrc", [qw(Foo Bar Baz Quux)]);

   my @directives = $config->directives;

   $config->get( "Foo" );
   
   if( $config->exists( "Bar" ) )
   		{
   		print "Bar was in the config file\n";
   		}
   

=head1 DESCRIPTION

   C<ConfigReader::Simple> reads and parses simple configuration files. It's
   designed to be smaller and simpler than the C<ConfigReader> module
   and is more suited to simple configuration files.

=cut


=head1 METHODS

=item new ( FILENAME, DIRECTIVES )

Creates a ConfigReader::Simple object.

C<FILENAME> tells the instance where to look for the configuration
file.

C<DIRECTIVES> is an optional argument and is a reference to an array.  
Each member of the array should contain one valid directive. A directive
is the name of a key that must occur in the configuration file. If it
is not found, the module will die. The directive list may contain all
the keys in the configuration file, a sub set of keys or no keys at all.

=cut

sub new 
	{
	my $class    = shift;
	my $filename = shift;
	my $keyref   = shift;
	
	my $self  = {};
	
	$self->{"filename"}  = $filename;
	$self->{"validkeys"} = $keyref;
	
	bless $self, $class;
	
	$self->parse();
	
	return $self;
	}

sub AUTOLOAD
	{
	my $self = shift;

	my $method = $AUTOLOAD;

	$method =~ s/.*:://;

	$self->get( $method );
	} 

sub DESTROY 
	{	
	return 1;
	}

=item parse ()

This does the actual work.  No parameters needed.

This is automatically called from C<new()>, although you can reparse
the configuration file by calling C<parse()> again.

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

=item get( DIRECTIVE )

Returns the parsed value for that directive.

=cut

sub get 
	{
	my $self = shift;
	my $key = shift;
	
	return $self->{"config_data"}{$key};
	}

=item directives()

Returns a list of all of the directive names found in the configuration
file. The keys are sorted ASCII-betically.

=cut

sub directives
	{
	my $self = shift;

	my @keys = sort keys %{ $self->{"config_data"} };

	return @keys;
	}

=item exists( DIRECTIVE )

=cut

sub exists
	{
	my $self = shift;
	my $name = shift;
	
	return CORE::exists $self->{"config_data"}{ $name };
	}
	
# Internal methods

sub parse_line {
   my $text = shift;

   my ($key, $value);

	# AWJ: Allow optional '=' or ' = ' between key and value:
   if ($text =~ /^\s*(\w+)\s*[=]?\s*(['"]?)(.*?)\2\s*$/ ) {
      $key = $1;
      $value = $3;
   } else {
      croak "Config: Can't parse line: $text\n";
   }

   return ($key, $value);
}


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
         	croak "Config: key '$declared_key' does not occur in file $self->{filename}\n";
      	}
         warn "Key: $declared_key found.\n" if $DEBUG;
      }
	}

   return 1;
}

=head1 LIMITATIONS/BUGS

Directives are case-sensitive.

If a directive is repeated, the first instance will silently be
ignored.

=head1 CREDITS

Kim Ryan <kimaryan@ozemail.com.au> adapted the module to make declaring
keys optional.  Thanks Kim.

Alan W. Jurgensen <jurgensen@berbee.com> added a change to allow
the NAME=VALUE format in the configuration file.


=head1 AUTHORS

Bek Oberin <gossamer@tertius.net.au>

now maintained by brian d foy <bdfoy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2000 Bek Oberin.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
