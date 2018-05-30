use v6;
use Test;

plan 22;

# L<S06/Closure parameters>

{
    my sub testit (&testcode) {testcode()}

    ok(testit({1}), 'code executes as testsub({...})');

    my $code = {1};
    ok(testit($code), 'code executes as testsub($closure)');

    my sub returntrue {return 1}
    ok(testit(&returntrue), 'code executes as testsub(&subroutine)');
}

# with a signature for the closure
{
    my sub testit (&testcode:(Int)) {testcode(12)}
    my sub testint(Int $foo) {return 1}   #OK not used
    my sub teststr(Str $foo) {return 'foo'}   #OK not used

    my sub test-but-dont-call(&testcode:(Int)) { True }

    ok(testit(&testint), 'code runs with proper signature (1)');
    throws-like 'testit(&teststr)', Exception, 'code dies with invalid signature (1)';

    ok(test-but-dont-call(&testint), 'code runs with proper signature (1)');
    throws-like 'test-but-dont-call(&teststr)', Exception, 'code dies with invalid signature (1)';
}

{
    my sub testit (&testcode:(Int --> Bool)) {testcode(3)}
    my Bool sub testintbool(Int $foo) {return Bool::True}   #OK not used
    my Bool sub teststrbool(Str $foo) {return Bool::False}   #OK not used
    my Int  sub testintint (Int $foo) {return 1}   #OK not used
    my Int  sub teststrint (Str $foo) {return 0}   #OK not used

    ok(testit(&testintbool), 'code runs with proper signature (2)');
    throws-like 'testit(&testintint)', Exception, 'code dies with invalid signature (2)';
    throws-like 'testit(&teststrbool)', Exception, 'code dies with invalid signature (3)';
    throws-like 'testit(&teststrint)', Exception,  'code dies with invalid signature (4)';
}

{
    multi sub t1 (&code:(Int)) { 'Int' };   #OK not used
    multi sub t1 (&code:(Str)) { 'Str' };   #OK not used
    multi sub t1 (&code:(Str --> Bool)) { 'Str --> Bool' };   #OK not used
    multi sub t1 (&code:(Any, Any)) { 'Two' };   #OK not used

    # Note that using &code:($,$) instead of &code:(Any, Any) makes this next test work
    #?rakudo skip 'subsignatures dont factor into multi candidates yet RT #124935'
    is t1(-> $a, $b { }), 'Two',   #OK not used
       'Multi dispatch based on closure parameter syntax (1)';
    is t1(-> Int $a { }), 'Int',   #OK not used
       'Multi dispatch based on closure parameter syntax (2)';
    is t1(-> Str $a { }), 'Str',   #OK not used
       'Multi dispatch based on closure parameter syntax (3)';

    sub takes-str-returns-bool(Str $x --> Bool) { True }   #OK not used
    is t1(&takes-str-returns-bool), 'Str --> Bool',
       'Multi dispatch based on closure parameter syntax (4)';

    dies-ok { t1( -> { 3 }) },
       'Multi dispatch based on closure parameter syntax (5)';
}

{
    sub foo(:&a) { bar(:&a) }
    sub bar(*%_) { "OH HAI" }
    is foo(), 'OH HAI', 'can use &a as a named parameter';
}

# RT #125988
{
    throws-like 'sub f (Int &b:(--> Bool)) { }', X::Redeclaration, 'only one way of specifying sub-signature return type allowed';
}

# RT #123116
lives-ok {
    my class Dog {};
    sub foo(&block:(Dog --> Bool)) {
        pass 'called sub in unpacking Callable signature with colon';
    }
    foo(sub (Dog $x --> Bool) { $x })
}, 'unpacking Callable signature with colon';

# https://github.com/rakudo/rakudo/issues/1326
subtest 'can use signature unpacking with anonymous parameters' => {
    plan 2;
    is -> &:(Str), 42 {100}(-> Str $v { $v.uc }, 42), 100,
        'can call with right signature';
    throws-like '-> &:(Int) {}({;})', X::TypeCheck::Binding::Parameter,
        'typcheck correctly fails with wrong arg';
}

# RT #132209
subtest 'can use signature with &-sigiled named parameters' => {
    plan 2;
    my $res = 0;
    sub x (:$param) { $param + 1 };
    sub x2 ($, :$param) { $param + 1 };
    sub c (:&funk:(:$param)) { funk :41param };
    is c(:funk(&x)), 42, 'can call with right signature';
    throws-like 'c(:funk(&x2))', X::TypeCheck::Binding::Parameter,
        'typcheck correctly fails with wrong arg';
}
# vim: ft=perl6
