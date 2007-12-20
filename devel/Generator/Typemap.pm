# $Id$
# $Source$
# $Author$
# $HeadURL$
# $Revision$
# $Date$
package devel::Generator::Typemap;

use strict;
use warnings;
use version;
use 5.00600;

our $AUTHORITY = 'cpan:ASKSH';
our $VERSION   = qv('2.0.0_08');

my @ALWAYS_EXPORT = qw(type alias WRITE_TYPES);

my %TYPES;
my %ALIASES;

sub import {
    my ($this_class, @tags) = @_;
    my $caller_class = caller 0;

    no strict 'refs'; ## no critic

    for my $sub (@ALWAYS_EXPORT) {
        *{ "$caller_class\::$sub" } = *{ "$this_class\::$sub" };
    }

    return;
}
        

sub type {
    my ($type_name, $type_data) = @_;

    my %type_data = $type_data->();

    $TYPES{$type_name} = \%type_data;

    return;
} 

sub alias {
    my ($alias, $points_to) = @_;

    $ALIASES{$alias} = $points_to;    

    return;
}

sub WRITE_TYPES {

    my $preample = do { local $/; <DATA> };

    print $preample;

    print q{# ------------ ALIASES ------------- #}, "\n";
    print q{our %__TYPEALIASES__ = (}, "\n";
    while (my ($pointer, $dest) = each %ALIASES) {
        print qq{    '$pointer' => '$dest',\n};
    }
    print q{);}, "\n\n";
    
    print q{# ------------ COMPAT -------------- #}, "\n";
    print q{our %__COMPAT_TYPESUBS__ = (}, "\n";
    while (my ($name, $data) = each %TYPES) {
        my $prototype = exists $data->{prototype} ? "($data->{prototype})"
            : q{};
        print <<"EOFCODE"
       '$name' => sub $prototype {
            my \$real_sub = \$INIT_TYPE{'$name'};
            goto &\$real_sub;
        },
EOFCODE
;
    }
    print q{);}, "\n\n";

    print q{# ------------ TYPES -------------- #}, "\n";
    print q{our %INIT_TYPE = (}, "\n";
    while (my ($name, $data) = each %TYPES) {
        my $prototype = exists $data->{prototype} ? "($data->{prototype})"
            : q{};
        my $constraint = $data->{constraint}    || q{};
        my $defval_gen = $data->{default_value} || q{};
        print <<"EOFCODE"

    '$name' => (subname "\${PKG}::create_type_$name" => sub $prototype {
        my (\@args) = \@_;

        my \$generator = subname "\${PKG}::isa_$name\_defval" => sub { $defval_gen
        };

        my \$constraint = subname "\${PKG}::isa_$name\_check" => sub { $constraint
        };

        return _create_type_instance("$name", \$generator, \$constraint);
    }),
EOFCODE
;
    print q{);}, "\n\n";


    print qq{1;\n},
          qq{__END__\n};
    }
   

}

1;

__DATA__

package ABBA;

use strict;
use warnings;
use version;
use 5.00600;

our $AUTHORITY = 'cpan:ASKSH';
our $VERSION   = qv('2.0.0_08');

use Class::Dot::Devel::Sub::Name;


my $PKG = __PACKAGE__;
