# $Id: Types.pm 57 2007-12-18 13:19:53Z asksol $
# $Source: /opt/CVS/Getopt-LL/lib/Class/Dot.pm,v $
# $Author: asksol $
# $HeadURL: https://class-dot.googlecode.com/svn/trunk/lib/Class/Dot/Types.pm $
# $Revision: 57 $
# $Date: 2007-12-18 14:19:53 +0100 (Tue, 18 Dec 2007) $
package Class::Dot::Types;

use strict;
use warnings;
use version qw(qv);
use 5.006000;

use Carp            qw(croak);
use Params::Util    qw(_ARRAYLIKE _HASHLIKE);
use English         qw(-no_match_vars);

BEGIN {
    eval 'require Sub::Name'; ## no critic
    if ($EVAL_ERROR) {
        *subname = sub {
            my ($sub_name, $sub_coderef) = @_;
            return $sub_coderef;
        };
    }
    else {
        Sub::Name->import('subname');
    }
}

our $VERSION   = qv('2.0.0_06');
our $AUTHORITY = 'cpan:ASKSH';

our @STD_TYPES = qw(
    isa_String isa_Int isa_Array isa_Hash
    isa_Data isa_Object isa_Code isa_File
);

my @EXPORT_OK = @STD_TYPES;

my %EXPORT_CLASS = (
   ':std'  => [@EXPORT_OK],
);

our %__TYPEDICT__ = (
   'Array'     => \&isa_Array,
   'Code'      => \&isa_Code,
   'Data'      => \&isa_Data,
   'File'      => \&isa_File,
   'Hash'      => \&isa_Hash,
   'Int'       => \&isa_Int,
   'Object'    => \&isa_Object,
   'String'    => \&isa_String,
);

my $TYPE_BASE_CLASS = 'DotX';

my $THIS_PKG = __PACKAGE__;

sub import { ## no critic
    my $this_class   = shift;
    my $caller_class = caller;

    my $export_class;
    my @subs;
    for my $arg (@_) {
        if ($arg =~ m/^:/xms) {
            croak(   'Only one export class can be used. '
                    ."(Used already: [$export_class] now: [$arg])")
                if $export_class;

            $export_class = $arg;
        }
        else {
            push @subs, $arg;
        }
    }

    my @subs_to_export
        = $export_class && $EXPORT_CLASS{$export_class}
        ? (@{ $EXPORT_CLASS{$export_class} }, @subs)
        : @subs;

    no strict 'refs'; ## no critic;
    for my $sub_to_export (@subs_to_export) {
        _install_sub_from_class($this_class, $sub_to_export => $caller_class);
    }

    return;
}

sub _install_sub_from_class {
    my ($pkg_from, $sub_name, $pkg_to) = @_;
    my $from = join q{::}, ($pkg_from, $sub_name);
    my $to   = join q{::}, ($pkg_to,   $sub_name);

    no strict 'refs'; ## no critic
    *{$to} = *{$from};

    return;
}

sub _subclass_name {
    my ($parent_class, $subclass_name) = @_;
    return join q{::}, $parent_class, $subclass_name;
}

sub _create_type_instance {
    my ($type, $isa) = @_;

    my $full_class_name = _subclass_name($TYPE_BASE_CLASS, $type);

    _create_class($full_class_name, {
            type            => (subname "${full_class_name}::type" => sub {
                    return $type;
            }),
            default_value   =>
                (subname "${full_class_name}::default_value" => sub {
                    my ($self)  = @_;
                    my $sub_ref = ${ $self };
                    return $sub_ref->();
            }),
        },
        [ $TYPE_BASE_CLASS ],
    );

    return bless \$isa, $full_class_name;
}

my $created_classes = { };
sub _create_class {
    my ($class_name, $methods_ref, $append_isa_ref, $version) = @_;
    return if exists $created_classes->{$class_name};

    $version = defined $version ? $version
        : 1.0;

    no strict 'refs';       ## no critic
    no warnings 'redefine'; ## no critic

    if (_ARRAYLIKE($append_isa_ref)) {
        my $isa_ref = \@{ "${class_name}::ISA" };
        push @{ $isa_ref }, @{ $append_isa_ref };
    }

    if (_HASHLIKE($methods_ref)) {
        while (my ($method_name, $method_code) = each %{ $methods_ref }) {
            *{ "${class_name}::$method_name" } = $method_code;
        }
    }

    ${ "${class_name}::VERSION" } = $version;

    $created_classes->{$class_name} = 1;

    return;
}


sub isa_String { ## no critic
    my ($default_value) = @_;

    my $generator = subname "${THIS_PKG}::isa_String_defval" => sub {
        return $default_value
            if defined $default_value;
        return;
    };

    return _create_type_instance('String', $generator);
}

sub isa_Int    { ## no critic
    my ($default_value) = @_;

    my $generator = subname "${THIS_PKG}::isa_Int_defval" => sub {
        return $default_value
            if defined $default_value;
        return;
    };

    return _create_type_instance('Int', $generator);
}

sub isa_Array  { ## no critic
    my @default_values = @_;

    my $generator = subname "${THIS_PKG}::isa_Array_defval" => sub {
        return scalar @default_values
            ? \@default_values
            : [ ];
    };

    return _create_type_instance('Array', $generator);
}

sub isa_Hash   { ## no critic
    my %default_values = @_;

    my $generator = subname "${THIS_PKG}::isa_Hash_defval" => sub {
        return scalar keys %default_values
            ? \%default_values
            : { };

        # have to test if there are any entries in the hash
        # so we return a new anonymous hash if it ain't.
    };

    return _create_type_instance('Hash', $generator);
}

sub isa_Data   { ## no critic
    my ($default_value) = @_;

    my $generator = subname "${THIS_PKG}::isa_Data_defval" => sub {
        return $default_value
            if defined $default_value;
        return;
    };

    return _create_type_instance('Data', $generator);
}

sub isa_Code (;&;) { ## no critic
    my $code_ref = shift;

    my $generator = subname "${THIS_PKG}::isa_Code_defval" => sub {
        return defined $code_ref ? $code_ref
            : subname 'lambda-non' => sub { };
    };

    return _create_type_instance('Code', $generator);
}

sub isa_File   { ## no critic
    my $filehandle = shift;
    
    my $generator = subname "${THIS_PKG}::isa_File_defval" => sub {
        if (defined $filehandle) {
            return $filehandle;
        }
        else {
            require FileHandle;
            return FileHandle->new( );
        }
    };

    return _create_type_instance('File', $generator);
}

sub isa_Object { ## no critic
    my $class = shift;
    my %opts;
    if (!scalar @_ % 2) {
        %opts = @_;
    }
    my $generator = subname "${THIS_PKG}::isa_Object_defval" => sub {
        return if not defined $class;
        if ($opts{auto}) {
            return        $class->new();
        }
        return;
    };

    return _create_type_instance('Object', $generator);
}

1;

__END__

=begin wikidoc

= NAME

Class::Dot::Types - Functions returning default values for Class::Dot types.

= VERSION

This document describes Class::Dot version v2.0.0 (beta 4).

= SYNOPSIS

    use Class::Dot::Types qw(:std);

    use Class::Dot::Types qw( isa_String isa_Int );


= DESCRIPTION

This module has the available types [Class::Dot] supports.

= SUBROUTINES/METHODS

== CLASS METHODS

=== {isa_String($default_value)}
=for apidoc CODEREF = Class::Dot::isa_String(data|CODEREF $default_value)

The property is a string.

=== {isa_Int($default_value)}
=for apidoc CODEREF = Class::Dot::isa_Int(int $default_value)

The property is a number.

=== {isa_Array(@default_values)}
=for apidoc CODEREF = Class::Dot::isa_Array(@default_values)

The property is an array.

=== {isa_Hash(%default_values)}
=for apidoc CODEREF = Class::Dot::isa_Hash(@default_values)

The property is an hash.

=== {isa_Object($kind)}
=for apidoc CODEREF = Class::Dot::isa_Object(string $kind)

The property is a object.
(Does not really set a default value.).

=== {isa_Data()}
=for apidoc CODEREF = Class::Dot::isa_Data($data)

The property is of a not yet defined data type.

=== {isa_Code()}
=for apidoc CODEREF = Class::Dot::isa_Code(CODEREF $code)

The property is a subroutine reference.

=== {isa_File()}
=for apidoc CODEREF = Class::Dot::isa_Code(FILEHANDLE $fh)


= DIAGNOSTICS

= CONFIGURATION AND ENVIRONMENT

This module requires no configuration file or environment variables.

= DEPENDENCIES

* [version]

= INCOMPATIBILITIES

None known.

= BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
[bug-class-dot@rt.cpan.org|mailto:bug-class-dot@rt.cpan.org], or through the web interface at
[CPAN Bug tracker|http://rt.cpan.org].

= SEE ALSO

== [Class::Dot]

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
