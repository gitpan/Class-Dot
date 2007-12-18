# $Id: Cat.pm 57 2007-12-18 13:19:53Z asksol $
# $Source: /opt/CVS/Getopt-LL/t/Cat.pm,v $
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/t/Cat.pm $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
package Cat;
use strict;
use warnings;
use FindBin qw($Bin);
use lib 'lib';
use lib $Bin;
use lib 't';
use lib "$Bin/../lib";
use Class::Dot qw( -new :std );
extends 'Mammal';
{

    # A cat's properties, with their default values and type of data.
    property gender      => isa_String('male');
    property memory      => isa_Hash;
    property state       => isa_Hash(instinct => 'hungry');
    property family      => isa_Array;
    #property dna         => isa_Data;
    property action      => isa_Data;
    property colour      => isa_Int(0xfeedface);
    property fur         => isa_Array('short');

    sub test_new {
        my ($self) = @_;
        return $self->{__test_new};
    }

    sub set_test_new {
        my ($self, $value) = @_;
        $self->{__test_new} = $value;
        return;
    }

    sub BUILD {
        my ($self, $options_ref) = @_;
        $self->set_test_new('BUILD and -new works!');
        return;
    }

    our $HAS_BEEN_DESTRUCTED = 0;
    sub DEMOLISH {
        $HAS_BEEN_DESTRUCTED = 1;
       return; 
    }
}

1;
__END__
 
     package main;
 
     my $albert = new Animal::Mammal::Carnivorous::Cat('male');
     $albert->memory->{name} = 'Albert';
     $albert->state->{appetite} = 'insane';
     $albert->set_fur([qw(short thin shiny)]);
     $albert->set_action('hunting');
 
     my $lucy = new Animal::Mammal::Carnivorous::Cat('female');
     $lucy->memory->{name} = 'Lucy';
     $lucy->state->{instinct => 'tired'};
     $lucy->set_fur([qw(fluffy long)]);
     $lucy->set_action('sleeping');
 
     push @{ $lucy->family   }, [$albert];
     push @{ $albert->family }, [$lucy  ];


1;

