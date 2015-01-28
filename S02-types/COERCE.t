use v6;
use Test;

plan 7;

my class CoercingValue {}

my class NonCoercingValue {
    method Str { '5' }
}

my class OverridingValue {
    has $.value;

    method invoke(OverridingValue:U: Int $value) { OverridingValue.new(:$value) }
}

my class SuperValue {}

my class SubValue is SuperValue {}

multi sub COERCE(CoercingValue $, Str) { '6' }

multi sub COERCE(SuperValue $, Str) { 'super' }

multi sub COERCE(SubValue $, Str) { 'sub' }

is COERCE(CoercingValue.new, Str), '6', 'COERCE should invoke the proper candidate if one is available';
is COERCE(NonCoercingValue.new, Str), '5', 'COERCE should invoke $dest_type as a method on the coercee if no specific candidate matches';
is Str(CoercingValue.new), '6', 'Invoking a type should make use of COERCE';
is Str(NonCoercingValue.new), '5', 'Invoking a type should make use of COERCE';

is OverridingValue(5).value, 5, "invoke should still be called if it's overriden by a class when using Type(...)";

is Str(SuperValue.new), 'super', 'coercing a class to a Str should pick the right candidate';
is Str(SubValue.new), 'sub', 'coercing a subclass to a Str should pick the more specific candidate';
