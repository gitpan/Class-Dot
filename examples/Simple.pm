# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package Class::Dot::Example::Simple;

use Class::Dot 2.0 qw(-new :std);

use XML::Simple;


property name => isa_String;

property email => isa_String;
property age   => isa_Int;

sub BUILD {
   my ($self, $options_ref) = @_;

   # name is required.
   croak 'Name is required' if not $self->name;

   return;
}

# Use XML::Simple to serialize this object instance as XML.
sub as_XML {
   my ($self) = @_;

   return XMLout({
      name  => $self->name,
      email => $self->email,
      age   => $self->age,
   });
}


1;


