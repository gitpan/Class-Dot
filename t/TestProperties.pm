# $Id: TestProperties.pm 57 2007-12-18 13:19:53Z asksol $
# $Source$
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/t/TestProperties.pm $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
package TestProperties;

use strict;
use warnings;

use Class::Dot qw(-new :std);
use FindBin qw($Bin);
use lib $Bin;
use Cat;
use English qw( -no_match_vars );

property foo            => isa_Data;
property bar            => isa_Data;
property xyzzy          => isa_Data('3.141592');
property defval         => isa_String('la liberation');
property array          => isa_Array(qw(the quick brown fox ...));
property hash           => isa_Hash(hello => 'world', goobye => 'wonderful');
property digit          => isa_Int(303);
property intnoval       => isa_Int;
property obj            => isa_Object('Cat', auto => 1);
property nofunc         => 'This does not use isa_*';
property 'nodefault';
property string         => isa_String();
property mystery_object => isa_Object();
property another_object => isa_Object('Cat', auto => 1, 'blah');
property code           => isa_Code;
property __private      => isa_String;
property _private       => isa_String;
property __private__    => isa_String;

composite compoze => 'Composite';

property reglazy        => sub { return "hello lazy!" };
property blessed        => bless { }, 'Some::XXX::Class';

if ($] >= 5.00800) {
   eval 'property codedef => isa_Code {return 10}';
}
else {
   property codedef => isa_Code sub {return 10};
}
   
property filehandle => isa_File;
open my $myself, '<', $PROGRAM_NAME;
property myself     => isa_File($myself);

property override  => isa_String('obladi oblada');
{
    my $MODIFY_ME = 'not modified';

    after_property_get override => sub {
        return $MODIFY_ME;        
    };

    after_property_set override => sub {
        my ($self, $value) = @_;
        $MODIFY_ME = $value;
        return;
    };

}

property override2 => isa_String('oblada obladi');
{
    my $MODIFY_ME = 'xxx not modified';
    
    sub override2 {
        return $MODIFY_ME;
    }

    sub set_override2 {
        my ($self, $value) = @_;
        $MODIFY_ME = $value;
        return;
    }
}


1;

__END__

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
# End:
# vim: expandtab tabstop=4 shiftwidth=4 shiftround
