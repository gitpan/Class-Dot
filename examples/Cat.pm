# $Id: Cat.pm 50 2007-11-03 21:59:03Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/examples/Cat.pm $
# $Revision: 50 $
# $Date: 2007-11-03 22:59:03 +0100 (Sat, 03 Nov 2007) $
package Animal::Mammal::Carnivorous::Cat;

use Class::Dot qw( :std );

# A cat's properties, with their default values and type of data.
property gender => isa_String('male');
property memory => isa_Hash;
property state  => isa_Hash( instinct => 'hungry' );
property family => isa_Array;
property dna    => isa_Data;
property action => isa_Data;
property colour => isa_Int(0xfeedface);
property fur    => isa_Array('short');

sub new {
    my ( $class, $gender ) = @_;
    my $self = {};    # Must be anonymous hash for Class::Dot to work.
    bless $self, $class;

    $self->set_gender($gender);

    warn sprintf(
        'A new cat is born, it is a %s. Weeeeh!',
        $self->gender
    );

    return $self;
}

sub run {
    while (1) {
        die if $self->state->{dead};
    }
}

package main;

my $albert = new Animal::Mammal::Carnivorous::Cat('male');
$albert->memory->{name}    = 'Albert';
$albert->state->{appetite} = 'insane';
$albert->set_fur( [qw(short thin shiny)] );
$albert->set_action('hunting');

my $lucy = new Animal::Mammal::Carnivorous::Cat('female');
$lucy->memory->{name} = 'Lucy';
$lucy->state->{ instinct => 'tired' };
$lucy->set_fur( [qw(fluffy long)] );
$lucy->set_action('sleeping');

push @{ $lucy->family },   [$albert];
push @{ $albert->family }, [$lucy];

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
