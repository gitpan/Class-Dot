# $Id: ClassDot.pm 57 2007-12-18 13:19:53Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/lib/Perl/Tags/ClassDot.pm $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
package Perl::Tags::ClassDot;

use strict;
use warnings;
use vars qw(@ISA $VERSION);
use version; $VERSION = qv('2.0.0_06');
use 5.00600;

@ISA = qw(Perl::Tags::Naive); ## no critic

use Perl::Tags;
use Data::Dumper;
use English qw(-no_match_vars);
use Perl::Tags::ClassDot::Tag::Property;

my $RE_PROPERTY = qr/
    ^\s*
        property\s*\(?
            (.+?) (?:\)|\s+|$|;)
                (?:\=\>\s*(.+))$
/xms;

sub get_parsers {
   my $self = shift;
   return (
      $self->can('property_line'),
      $self->SUPER::get_parsers()
   );
}

sub property_line {

# has to be put before 'trim' parser, otherwise the comment line will have gone!
   my ( $self, $line, $statement, $file ) = @_;

   return if not defined $statement;
   if ($statement =~ $RE_PROPERTY) {
      my ($name, $type) = ( q{}, 'isa_Anything' );
      if (defined $1) {
        $name = $1;
      };
      if (defined $2) {
        $type = $2;
      }

      $type =~ s/^isa_/is /xms;
      $type =~ s/\;$//xms;

      return Perl::Tags::ClassDot::Tag::Property->new(
         name    => "$name $type",
         file    => $file,
         line    => $line,
         linenum => $INPUT_LINE_NUMBER,
      );
   }
   return;
}

1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround

=begin wikidoc

= NAME

Perl::Tags::ClassDot - perltags with support for Class::Dot

= VERSION

This document describes Class::Dot version v2.0.0 (beta 4).

= SYNOPSIS

See [Perl::Tags] for more information!

= DESCRIPTION

This is a subclass of Perl::Tags that adds tagging of Class::Dot
properties.

= SUBROUTINES/METHODS

== CLASS METHODS

=== {property_line()}

This [Perl::Tags] parser filter recognizes [Class::Dot] properties
in Perl source code.

=== {get_parsers()}

See [Perl::Tags] for information about this method.

= DIAGNOSTICS

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [Perl::Tags]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the web interface at
[CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Perl::Tags]

This module is a subclass of [Perl::Tags::Naive].

= AUTHOR

Ask Solem, [ask@0x61736b.net].


= LICENSE AND COPYRIGHT

Copyright (c), 2007 Ask Solem [ask@0x61736b.net|mailto:ask@0x61736b.net].

{Class::Dot} is distributed under the Modified BSD License.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this
list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. The name of the author may not be used to endorse or promote products derived
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

= DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE
SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE
STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE
SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND
PERFORMANCE OF THE SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE,
YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY
COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR REDISTRIBUTE THE
SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR
THIRD PARTIES OR A FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER
SOFTWARE), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

=end wikidoc

=for stopwords vim expandtab shiftround

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
