# $Id$
package ConfigReader::Simple;
use strict;

use subs qw(_init_errors);
use vars qw($VERSION $AUTOLOAD $Warn %ERROR $ERROR $Warn $Die);

use Carp qw(croak carp);

$Die   = '';
$ERROR = '';
( $VERSION ) = sprintf "%d.%02d", q$Revision$ =~ m/ (\d+) \. (\d+) /gx;
$Warn = 0;

my $DEBUG = 0;
my $Error = '';


=head1 NAME

ConfigReader::Simple - Simple configuration file parser

=head1 SYNOPSIS

	use ConfigReader::Simple;

	# parse one file
	$config = ConfigReader::Simple->new("configrc", [qw(Foo Bar Baz Quux)]);

	# parse multiple files, in order
	$config = ConfigReader::Simple->new_multiple(
		Files => [ "global", "configrc" ], 
		Keys  => [qw(Foo Bar Baz Quux)]
		);

	my @directives = $config->directives;

	$config->get( "Foo" );

	if( $config->exists( "Bar" ) )
   		{
   		print "Bar was in the config file\n";
   		}


=head1 DESCRIPTION

C<ConfigReader::Simple> reads and parses simple configuration files. It is
designed to be smaller and simpler than the C<ConfigReader> module
and is more suited to simple configuration files.

=head2 Methods

=over 4

=item new ( FILENAME, DIRECTIVES )

Creates a ConfigReader::Simple object.

C<FILENAME> tells the instance where to look for the
configuration file. If FILENAME cannot be found, an error
message for the file is added to the %ERROR hash with the
FILENAME as a key, and a combined error message appears in
$ERROR.

C<DIRECTIVES> is an optional argument and is a reference to
an array. Each member of the array should contain one valid
directive. A directive is the name of a key that must occur
in the configuration file. If it is not found, the method
croaks. The directive list may contain all the keys in the
configuration file, a sub set of keys or no keys at all.

The C<new> method is really a wrapper around C<new_multiple>.

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

This function croaks if the values are not array references.

If this method cannot read a file, an error message for that
file is added to the %ERROR hash with the filename as a key,
and a combined error message appears in $ERROR.  Processing
the list of filenames continues if a file cannot be found,
which may produced undesired results. You can disable this
feature by setting the $ConfigReader::Simple::Die variable
to a true value.

=cut

sub new_multiple
	{
	_init_errors();
	
	my $class    = shift;
	my %args     = @_;

	my $self = {};
	
	$args{'Keys'} = [] unless defined $args{'Keys'};
	
	croak( __PACKAGE__ . ': Strings argument must be a array reference')
		unless UNIVERSAL::isa( $args{'Files'}, 'ARRAY' );
	croak( __PACKAGE__ . ': Keys argument must be an array reference')
		unless UNIVERSAL::isa( $args{'Keys'}, 'ARRAY' );
		
	$self->{"filenames"} = $args{'Files'};
	$self->{"validkeys"} = $args{'Keys'};
	
	bless $self, $class;
	
	foreach my $file ( @{ $self->{"filenames"} } )
		{
		my $result = $self->parse( $file );
		croak $Error if( not $result and $Die );
		
		$ERROR{$file} = $Error unless $result;
		}
		
	$ERROR = join "\n", map { $ERROR{$_} } keys %ERROR;
	
	return $self;
	}

=item new_string( Strings => ARRAY_REF, Keys => ARRAY_REF )

Create a configuration object from several strings listed
in the anonymous array value for the C<Strings> key.  The
module reads the strings in the same order that they appear
in the array.  Later values override earlier ones.  This
allows you to specify global configurations which you 
may override with more specific ones:

	ConfigReader::Simple->new_strings(
		Strings => [ \$global, \$local ],
		);

This function croaks if the values are not array references.

=cut

sub new_string
	{
	_init_errors;
	
	my $class = shift;
	my %args  = @_;
	
	my $self = {};
	
	$args{'Keys'} = [] unless defined $args{'Keys'};

	croak( __PACKAGE__ . ': Strings argument must be a array reference')
		unless UNIVERSAL::isa( $args{'Strings'}, 'ARRAY' );
	croak( __PACKAGE__ . ': Keys argument must be an array reference')
		unless UNIVERSAL::isa( $args{'Keys'}, 'ARRAY' );

	bless $self, $class;

	$self->{"strings"} = $args{'Strings'};
	$self->{"validkeys"} = $args{'Keys'};
	
	foreach my $string ( @{ $self->{"strings"} } )
		{
		$self->parse_string( $string );
		}
		
	return $self;
	}
	
=item add_config_file( FILENAME )

Parse another configuration file and add its directives to the
current configuration object. Any directives already defined 
will be replaced with the new values found in FILENAME.

=cut

sub add_config_file
	{
	_init_errors;
	
	my $self     = shift;
	my $filename = shift;
	
	return unless ( -e $filename and -r _ );
	
	push @{ $self->{"filenames"} }, $filename
		if $self->parse( $filename );
	
	return 1;
	}
	
sub new_from_prototype
	{
	_init_errors

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

This does the actual work.

This is automatically called from C<new()>, although you can reparse
the configuration file by calling C<parse()> again.

=cut

sub parse 
	{
	my $self = shift;
	my $file = shift;
	
	$Error = '';
	
	unless( open CONFIG, $file )
		{
		$Error = "Could not open configuration file [$file]: $!";
		
		carp "Could not open configuration file [$file]: $!" if
			$Warn;
			
		return;
		}
	
	while( <CONFIG> )
		{
		chomp;
		next if /^\s*(#|$)/; 
		
		my ($key, $value) = &parse_line($_);
		carp "Key:  '$key'   Value:  '$value'\n" if $DEBUG;
		
		$self->{"config_data"}{$key} = $value;
		}
		
	close(CONFIG);
	
	$self->_validate_keys;
	
	return 1;
	}

=item parse_from_string( SCALAR_REF )

Parses the string inside the reference SCALAR_REF just as if
it found it in a file.

=cut

sub parse_string
	{
	my $self   = shift;
	my $string = shift;
	
	my @lines = split /\r?\n/, $$string;
	
	foreach my $line ( @lines )
		{
		next if $line =~ /^\s*(#|$)/; 
		
		my ($key, $value) = &parse_line($line);
		carp "Key:  '$key'   Value:  '$value'\n" if $DEBUG;
		
		$self->{"config_data"}{$key} = $value;
		}
			
	$self->_validate_keys;
	
	return 1;
	}
	
=item get( DIRECTIVE )

Returns the parsed value for that directive.  For directives
which did not have a value in the configuration file, C<get>
returns the empty string.

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

sub _init_errors
	{
	%ERROR = ();
	$Error = undef;
	$ERROR = undef;
	}
	
# =item _validate_keys

# If any keys were declared when the object was constructed,
# check that those keys actually occur in the configuration file.
# This function croaks if a declared key does not exist.

# =cut

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
         
         	carp "Key: $declared_key found.\n" if $DEBUG;
			}
		}

	return 1;
	}

=back

=head2 Package variables

=over 4

=item $Die

If set to a true value, all errors are fatal.

=item $ERROR

The last error message.

=item %ERROR

The error messages from unreadable files.  The key is
the filename and the value is the error message.

=item $Warn

If set to a true value, methods may output warnings.

=back

=head1 LIMITATIONS/BUGS

Directives are case-sensitive.

If a directive is repeated, the first instance will silently be
ignored.

=head1 CREDITS

Bek Oberin <gossamer@tertius.net.au> wote the original module

Kim Ryan <kimaryan@ozemail.com.au> adapted the module to make declaring
keys optional.  Thanks Kim.

Alan W. Jurgensen <jurgensen@berbee.com> added a change to allow
the NAME=VALUE format in the configuration file.

=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	https://sourceforge.net/projects/brian-d-foy/
	
If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHORS

brian d foy, E<lt>bdfoy@cpan.orgE<gt>, currently maintained
by Andy Lester E<lt>petdance@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (c) 2002-2003 brian d foy.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
