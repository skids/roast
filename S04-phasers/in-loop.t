use v6;

use Test;

plan 31;

# TODO, based on synopsis 4:
#
# * KEEP, UNDO, PRE, POST, CONTROL
#   CATCH is tested in S04-statements/try.t
#                  and S04-exception-handlers/catch.t
#
# * $var will undo, etc
#
# * LEAVE type blocks in the context of CATCH
#
# * PRE/POST in classes is not the same as LEAVE/ENTER

# L<S04/"Phasers">

#?rakudo todo "NEXT/LEAVE ordering RT #124952"
{
    my $str;

    for 1..10 -> $i {
        last if $i > 3;
        $str ~= "($i a)";
        next if $i % 2 == 1;
        $str ~= "($i b)";
        LAST  { $str ~= "($i Lst)" }
        LEAVE { $str ~= "($i Lv)"  }
        NEXT  { $str ~= "($i N)"   }
        FIRST { $str ~= "($i F)"   }
        ENTER { $str ~= "($i E)"   }
    }

    is $str, "(1 F)(1 E)(1 a)" ~ "(1 N)(1 Lv)" ~
                  "(2 E)(2 a)(2 b)(2 N)(2 Lv)" ~
                  "(3 E)(3 a)" ~ "(3 N)(3 Lv)" ~
                  "(4 E)"  ~          "(4 Lv)(4 Lst)",
       'trait blocks work properly in for loop';
}

#?rakudo todo "NEXT/LEAVE ordering RT #124952"
{
    my $str;

    for 1..10 -> $i {
        last if $i > 3;
        $str ~= "($i a)";

        ENTER { $str ~= "($i E1)"   }
        LAST  { $str ~= "($i Lst1)" }
        FIRST { $str ~= "($i F1)"   }
        LEAVE { $str ~= "($i Lv1)"  }

        next if $i % 2 == 1;
        $str ~= "($i b)";

        LAST  { $str ~= "($i Lst2)" }
        NEXT  { $str ~= "($i N1)"   }
        FIRST { $str ~= "($i F2)"   }
        LEAVE { $str ~= "($i Lv2)"  }
        ENTER { $str ~= "($i E2)"   }
        NEXT  { $str ~= "($i N2)"   }
    }

    is $str,
"(1 F1)(1 F2)(1 E1)(1 E2)(1 a)" ~ "(1 N2)(1 N1)" ~  "(1 Lv2)(1 Lv1)" ~
            "(2 E1)(2 E2)(2 a)(2 b)(2 N2)(2 N1)" ~  "(2 Lv2)(2 Lv1)" ~
            "(3 E1)(3 E2)(3 a)" ~ "(3 N2)(3 N1)" ~  "(3 Lv2)(3 Lv1)" ~
            "(4 E1)(4 E2)"  ~                       "(4 Lv2)(4 Lv1)" ~ "(4 Lst2)(4 Lst1)",
       'trait blocks work properly in for loop';
}

# RT #122011
{
    my $str = "";

    for 10..1 -> $i {
        LAST  { $str ~= "(this should not happen)" }
    }

    is $str, "",
       'LAST does not fire for empty loop';
}

# RT #121145
{
    my $rt121156;
    my $i = 0;
    while $i < 6 {
        LEAVE { last };
        $i++;
        $rt121156 ~= $i;
    }
    is $rt121156, '1',
        '"last" statement called by LEAVE breaks out of while loop';

    $rt121156 = '';
    $i = 0;
    while $i < 3 {
        LEAVE { $rt121156 ~= "leaving" };
        $i++;
        $rt121156 ~= $i;
    }
    #?rakudo.jvm todo 'this test works "standalone", but not after previous test; RT #121145'
    is $rt121156, '1leaving2leaving3leaving',
        'LEAVE in while loop works as expected';
}

# RT #122134
{
    my $rt122134;
    for 1 { last; ENTER { $rt122134 = "hurz" } };
    is $rt122134, 'hurz', 'no UnwindException with "last" and "ENTER" in for loop';
}

# RT #126001
{
    sub rt126001_a () { for 1, 2 { LAST return $_ } };
    sub rt126001_b () { for 1, 2 -> $x { LAST { return $x } } };
    is rt126001_a(), 2, 'LAST phaser with block does not put Mu in the iteration variable';
    is rt126001_b(), 2, 'LAST phaser without block does not put Mu in the iteration variable';
}

{
    my (@first, @next, @last);
    sub foo($a) {
        for ^$a {
            FIRST @first.push($a);
            NEXT @next.push($a);
            LAST @last.push($a);
            foo($a - 1)
        }
    }
    foo(3);
    is @first, [3, 2, 1, 1, 2, 1, 1, 2, 1, 1],
        'FIRST in loop works fine with recursion';
    #?rakudo.jvm todo "got '2 3 2 3 3 2 3 2 3 3 2 3 2 3 3'"
    is @next, [1, 2, 1, 2, 3, 1, 2, 1, 2, 3, 1, 2, 1, 2, 3],
        'NEXT in loop works fine with recursion';
    #?rakudo.jvm todo "got '2 2 3 2 2 3 2 2 3 3'"
    is @last, [1, 1, 2, 1, 1, 2, 1, 1, 2, 3],
        'LAST in loop works fine with recursion';
}

# RT #125488
{
  $_ = Any;

  {
    my @a = [];
    for ^10 { NEXT @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'NEXT can see outer $_ in for loop';
  }

  {
    my @a = [];
    for ^10 { LAST @a.push($_) }
    is @a, [9], 'LAST can see outer $_ in for loop';
  }

  {
    my @a = [];
    for ^10 { POST @a.push($_); 42 }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'POST should topicalize block result not outer $_ in for loop';
  }

  #?rakudo todo 'KEEP should topicalize block result not outer $_'
  {
    my @a = [];
    for ^10 { KEEP @a.push($_); 42 }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'KEEP should topicalize block result not outer $_ in for loop';
  }


  #?rakudo todo 'POST should topicalize block (methodcall) result not outer $_ in for loop'
  # Method call results may parse differently than stuff that
  # would normally warn with a 'useless use', which was causing the
  # next two tests cases to fail on rakudo.
  {
    my @a = [];
    for ^10 { POST @a.push($_); 42.Int }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'POST should topicalize block (methodcall) result not outer $_ in for loop';
  }

  #?rakudo todo 'KEEP should topicalize block (methodcall) result not outer $_ in for loop'
  {
    my @a = [];
    for ^10 { KEEP @a.push($_); 42.Int }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'KEEP should topicalize block (methodcall) result not outer $_ in for loop';
  }

  # to prevent regressions from happening
  {
    my @a = [];
    for ^10 { FIRST @a.push($_) }
    is @a, [0], 'LAST can see outer $_ in for loop';
  }

  {
    my @a = [];
    for ^10 { LEAVE @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'LEAVE can see outer $_ in for loop';
  }

  {
    my @a = [];
    for ^10 { PRE @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'PRE can see outer $_ in for loop';
  }

  {
    my @a = [];
    for ^10 { UNDO @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'UNDO can see outer $_ in for loop';
  }

  # While/repeat/until loops are likely to parse through a different
  # path than for loops.

  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { NEXT @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'NEXT can see outer $_ in while loop';
  }

  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { LAST @a.push($_) }
    is @a, [10], 'LAST can see outer $_ in while loop';
  }

  #?rakudo todo 'POST should topicalize block result not outer $_ in while loop'
  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { POST @a.push($_); 42 }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'POST should topicalize block result not outer $_ in while loop';
  }

  #?rakudo todo 'KEEP should topicalize block result not outer $_ in while loop'
  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { KEEP @a.push($_); 42 }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'KEEP should topicalize block result not outer $_ in while loop';
  }

  #?rakudo todo 'POST should topicalize block (methodcall) result not outer $_ in while loop'
  # Method call results may parse differently than stuff that
  # would normally warn with a 'useless use'.
  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { POST @a.push($_); 42.Int }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'POST should topicalize block (methodcall) result not outer $_ in while loop';
  }

  #?rakudo todo 'KEEP should topicalize block (methodcall) result not outer $_ in while loop'
  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { KEEP @a.push($_); 42.Int }
    is @a, [42, 42, 42, 42, 42, 42, 42, 42, 42, 42], 'KEEP should topicalize block (methodcall) result not outer $_ in while loop';
  }

  # to prevent regressions from happening
  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { FIRST @a.push($_) }
    is @a, [0], 'LAST can see outer $_ in while loop';
  }

  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { LEAVE @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'LEAVE can see outer $_ in while loop';
  }

  #?rakudo todo 'PRE can see outer $_ in while loop'
  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { PRE @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'PRE can see outer $_ in while loop';
  }

  {
    my @a = []; $_ = -1;
    while ++$_ < 10 { UNDO @a.push($_) }
    is @a, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 'UNDO can see outer $_ in while loop';
  }

}

# vim: ft=perl6
