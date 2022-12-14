package MooseX::ShortHas;

use strictures 2;

# VERSION

# ABSTRACT: shortcuts for common Moose has attribute configurations

# COPYRIGHT

=head1 SYNOPSIS

Instead of:

    use Moose;
    
    has hro => is => ro => required => 1;
    has hlazy => is => lazy => builder => sub { 2 };
    has hrwp => is => rwp => required => 1;
    has hrw => is => rw => required => 1;

You can now write:

    use Moose;
    use MooseX::ShortHas;
    
    ro "hro";
    lazy hlazy => sub { 2 };
    rwp "hrwp";
    rw "hrw";

And options can be added or overriden by appending them:

    ro hro_opt => required => 0;

=head1 DESCRIPTION

L<Moose>'s C<has> asks developers to repeat themselves a lot to set up
attributes, and since its inceptions the most common configurations of
attributes have crystallized through long usage.

This module provides sugar shortcuts that wrap around has under the appropriate
names to reduce the effort of setting up an attribute to naming it with a
shortcut.

=head1 EXPORTS

=head2 ro, rwp, rw

These three work the same, they convert a call like this:

    ro $name => @extra_args;

To this corresponding has call:
    
    has $name => is => ro => required => 1 => @extra_args;

The appending of extra args  makes it easy to override the required if
necessary.

=head2 lazy

This one is slightly different than the others, as lazy arguments don't require
a constructor value, but almost always want a builder of some kind:

    lazy $name => @extra_args;

Corresponds to:
    
    has $name => is => lazy => builder => @extra_args;

The first extra argument is thus expected to be any of the values appropriate
for the builder option.

=head1 SEE ALSO

=over

=item *
 
L<Muuse> - automatically wraps this module into Moose

=item *
 
L<Muuse::Role> - automatically wraps this module into Moose::Role

=item *

L<MooX::ShortHas>, L<Mu> - the Moo-related predecessors of this module

=item *

L<MooseX::MungeHas> - a different module for creating your own has on all of
Moo/Moose/Mouse

=back

=cut

use Moose::Exporter;
use Sub::Install 'install_sub';
use MooseX::AttributeShortcuts ();

sub _modified_has {
    my ($mods) = @_;
    sub {
        @_ = ( shift, shift, @{$mods}, @_ );
        goto &Moose::has;
    };
}

my %mods = (
    lazy => [ is => "lazy", builder => ],
    map +( $_ => [ is => $_, required => 1 ] ), qw( ro rwp rw ),
);
install_sub { into => __PACKAGE__, as => $_, code => _modified_has $mods{$_} }
  for keys %mods;

Moose::Exporter->setup_import_methods    #
  ( with_meta => [ keys %mods ], also => "MooseX::AttributeShortcuts" );

1;
