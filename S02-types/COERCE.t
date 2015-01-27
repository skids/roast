use v6;
use Test;

plan 4;

my class CoercingValue {}

my class NonCoercingValue {
    method Str { '5' }
}

multi sub COERCE(CoercingValue $, Str) { '6' }

is COERCE(CoercingValue.new, Str), '6', 'COERCE should invoke the proper candidate if one is available';
is COERCE(NonCoercingValue.new, Str), '5', 'COERCE should invoke $dest_type as a method on the coercee if no specific candidate matches';
is Str(CoercingValue.new), '6', 'Invoking a type should make use of COERCE';
is Str(NonCoercingValue.new), '5', 'Invoking a type should make use of COERCE';

# XXX overriding postcircumfix:<( )>
# XXX passing a Capture to ↑
# XXX named parameters
# XXX Type($parcel, $of, $arguments)
# XXX COERCE candidates with super/sub types
