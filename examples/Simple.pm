# $Id: Simple.pm 23 2007-10-29 17:11:24Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/class-dot/examples/Simple.pm $
# $Revision: 23 $
# $Date: 2007-10-29 18:11:24 +0100 (Mon, 29 Oct 2007) $
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


