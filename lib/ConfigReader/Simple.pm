package ConfigReader::Simple;
use strict;

# $Id$

use vars qw($VERSION $AUTOLOAD);

use Carp qw(croak);

( $VERSION ) = sprintf "%d.%02d", q$Revision$ =~ m/ (\d+) \. (\d+) /gx;

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
	
	$keyref = [] unless defined $keyref;
	
	my $self = $class->new_multiple( 
		Files => [ $filename ],
		Keys  => $keyref );
			
	return $self;
	}

=item new_multiple( Files => ARRAY_REF, Keys => ARRAY_REF )

Create a configuration object from several files listed
in the anonymous array value for the C<Files> key.  The
module reads the files in the same order that they appear
in the array.  Later values override earlier ones.  This
allows you to specify global configurations which you 
may override with more specific ones:

	ConfigReader::Simple->new_multiple(
		Files => [ qw( /etc/config /usr/local/etc/config /home/usr/config ) ],
		);

This function carps if the values are not array references.

=cut
	
sub new_multiple
	{
	my $class    = shift;
	my %args     = @_;

	my $self = {};
	
	$args{'Keys'} = [] unless defined $args{'Keys'};
	
	carp( __PACKAGE__ . ': Files argument must be an array reference')
		unless ref $args{'Files'} eq 'ARRAY';
	carp( __PACKAGE__ . ': Keys argument must be an array reference')
		unless ref $args{'Keys'} eq 'ARRAY';
		
	$self->{"filenames"} = $args{'Files'};
	$self->{"validkeys"} = $args{'Keys'};
	
	bless $self, $class;
	
	foreach my $file ( @{ $self->{"filenames"} } )
		{
		$self->parse( $file );
		}
		
	return $self;
	}
	
sub new_from_prototype
	{
	my $self     = shift;
	my $filename = shift;
	
	my $clone = $self->clone;
	
	return $clone;
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

=item parse( FILENAME )

This does the actual work.  No parameters needed.

This is automatically called from C<new()>, although you can reparse
the configuration file by calling C<parse()> again.

=cut

sub parse 
	{
	my $self = shift;
	my $file = shift;
	
	open CONFIG, $file or die "Cannot open file $file: $!";
	
	while( <CONFIG> )
		{
		chomp;
		next if /^\s*(#|$)/; 
		
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
	my $key  = shift;
	
	return $self->{"config_data"}{$key};
	}

=item set( DIRECTIVE, VALUE )

Sets the value for DIRECTIVE to VALUE.  The DIRECTIVE
need not already exist.  This overwrites previous 
values.

=cut

sub set 
	{
	my $self = shift;
	my( $key, $value ) = @_;
	
	$self->{"config_data"}{$key} = $value;
	}

=item unset( DIRECTIVE )

Remove the value from DIRECTIVE, which will still exist.  It's
value is undef.  If the DIRECTIVE does not exist, it will not
be created.  Returns FALSE if the DIRECTIVE does not already
exist, and TRUE otherwise.

=cut

sub unset
	{
	my $self = shift;
	my $key  = shift;
	
	return unless $self->exists( $key );
	
	$self->{"config_data"}{$key} = undef;
	
	return 1;
	}

=item remove( DIRECTIVE )

Remove the DIRECTIVE. Returns TRUE is DIRECTIVE existed
and FALSE otherwise.   

=cut

sub remove
	{
	my $self = shift;
	my $key  = shift;
	
	return unless $self->exists( $key );
	
	delete $self->{"config_data"}{$key};
	
	return 1;
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

Return TRUE if the specified directive exists, and FALSE
otherwise.  

=cut

sub exists
	{
	my $self = shift;
	my $name = shift;
	
	return CORE::exists $self->{"config_data"}{ $name };
	}

=item clone

Return a copy of the object.  The new object is distinct
from the original.

=cut

# this is only the first stab at this -- from 35,000
# feet in coach class
sub clone
	{
	my $self = shift;
	
	my $clone = {};
	
	$clone->{"filename"}  = $self->{"filename"};
	$clone->{"validkeys"} = $self->{"validkeys"};
	
	foreach my $key ( keys %{ $self->{'config_data'} } )
		{
		$clone->{'config_data'}{$key} = $self->{'config_data'}{$key};
		}
			
	bless $clone, __PACKAGE__;
	
	return $clone;
	}

# Internal methods

sub parse_line 
	{
	my $text = shift;
	
	my ($key, $value);
	
	# AWJ: Allow optional '=' or ' = ' between key and value:
	if ($text =~ /^\s*(\w+)\s*[=]?\s*(['"]?)(.*?)\2\s*$/ ) 
		{
		( $key, $value ) = ( $1, $3 );
		} 
	else 
		{
		croak "Config: Can't parse line: $text\n";
		}
	
	return ($key, $value);
	}


=item _validate_keys ( )

If any keys were declared when the object was constructed,
check that those keys actually occur in the configuration file.

=cut


sub _validate_keys 
	{
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
