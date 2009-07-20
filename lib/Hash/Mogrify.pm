package Hash::Mogrify;

use 5.010000;
use strict;
use warnings;

=head1 NAME

Hash::Mogrify - Perl extension for modifying hashes

=head1 SYNOPSIS

  use Hash::Mogrify qw(kmap vmap hmap);
  or
  use Hash::Mogrify qw(kmap vmap hmap :force :nowarning);

  my %hash = ( foo  => 'bar',
               quuz => 'quux',
               bla  => 'bulb',);

  my %newhash     = kmap { $_ =~ s/foo/food/ } %hash;
  my $newhashref  = vmap { $_ =~ s/bulb/burp/ } %hash;
  my $samehashref = hmap { $_[0] =~ s/foo/food/; $_[1] =~ s/bulb/burp/ } \%hash;
      
=head1 DESCRIPTION

Hash::Mogrify contains functions for changes parts of hashes, mogrify it's keys or it's values.

The functions are a bit overloaded^W flexible in design.
All functions return the list in list context, or the hashref in scalar context
The first argument is a code block to mogrify the hash, the second either a hash or a hashref.

Incase of a hash the hash is copied, otherwise the original hash is overwritten.

By default no function overwrites existing keys and warns about this when trying. 
this can be changed by using :force and :nowarning

=head2 EXPORT

None by default.

=cut 

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    hmap
    kmap
    vmap
) ],
    nowarning => [],
    force     => []);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

our $WARNING = 1;
our $FORCE = 0;

sub import {
    $FORCE = 1   if(grep /force/, @_);
    $WARNING = 0 if(grep /nowarning/, @_);
    
    Hash::Mogrify->export_to_level(1, @_);
}

sub kmap(&@) {
    my $code = shift;
    my $hash = $_[0];
    $hash = { @_ } if(!ref $hash);

    my $temp;
    for(keys(%{ $hash })) {
        my $value = $hash->{$_};
        &{$code};
        _double($temp, $_) or return;
        $temp->{$_} = $value;
    }
    %{$hash} = %{$temp};

    return %{$hash} if wantarray;
    return $hash;
}

sub vmap(&@) {
    my $code = shift;
    my $hash = $_[0];
    $hash = { @_ } if(!ref $hash);

    my $temp;
    for my $key (keys(%{ $hash })) {
        $_ = $hash->{$key};
        &{$code};
        $temp->{$key} = $_;
    }
    %{$hash} = %{$temp};

    return %{$hash} if wantarray;
    return $hash;
}

sub hmap(&@) {
    my $code = shift;
    my $hash = $_[0];
    $hash = { @_ } if(!ref $hash);

    my $temp;
    for my $key (keys(%{ $hash })) {
        my $value = $hash->{$key};
        &$code($key, $value);
        _double($temp, $key) or return;
        $temp->{$key} = $value;
    }
    %{$hash} = %{$temp};

    return %{$hash} if wantarray;
    return $hash;
}

sub _double {
    my ($hash, $key) = @_;
    return 1 if(!exists $hash->{$key});
    if($WARNING) {
        warn("Value: $_[0]");
        warn('Attempting to override existing key, failing.') if(!$FORCE);
        warn('Attempting to override existing key, forcing.') if($FORCE);
    }
    return $FORCE;
}
1;
__END__


=head1 SEE ALSO

L<Util::List>, L<Hash::Util>

=head1 AUTHOR

Sebastian Stellingwerff, E<lt>cpan@web.expr42.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Sebastian Stellingwerff

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
