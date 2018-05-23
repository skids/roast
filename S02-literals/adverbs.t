use v6;
use Test;

plan 86;

# L<S02/Adverbial Pair forms>

{
    is-deeply (:a), (a => True), "Basic boolean adverb works";
    is-deeply (:!a), (a => False), "Negated boolean adverb works";
    is-deeply (:a(0)), (a => 0), "Adverb with value in parens works";
    is-deeply (:a<foo>), (a => 'foo'), "Adverb with angle quote value works";
    is-deeply (:a<foo bar>), (a => <foo bar>), "...and does the right thing with the value list";
    is-deeply (:a[16,42]), (a => [16,42]), "Adverb with postfix:<[ ]> works";
    my $a = "abcd";
    my @a = <efg hij>;
    my %a = klm => "nop";
    my &a = ->{ "qrst" };
    is-deeply (:$a), (a => $a), ":$a works";
    is-deeply (:@a), (a => @a), ":@a works";
    is-deeply (:%a), (a => %a), ":%a works";
    is-deeply (:&a), (a => &a), ":&a works";
    is-deeply (:42nd), (nd => 42), "Basic numeric adverb works";
    #?rakudo.jvm todo 'RT #128306'
    #?rakudo.js todo 'unimplemented unicody thing'
    is-deeply (:๔߂nd), (nd => 42), "Unicode numeric adverb works"; # RT #128306
    throws-like { EVAL ':69th($_)' },
      X::Comp,
      "Numeric adverb can't have an extra value";

    is (:a{ 42 + 24 })<a>(), 66, "Adverb with postfix:<{ }> makes code object";

=twigils

    is-deeply (:$=pod), (pod => $=pod), 'Adverb with $= twigil works';
    # save for when @=COMMENT works
    # is-deeply (:@=COMMENT), (COMMENT => @=COMMENT), 'Adverb with @= twigil works';
    # There is no %= special variable yet
    is-deeply (:$?PACKAGE), (PACKAGE => $?PACKAGE), 'Adverb with $? twigil works';
    # There is no @? special variable yet
    # save for when %?LANG works
    # is-deeply (:%?LANG), (LANG => %?LANG), 'Adverb with %? twigil works';
    is-deeply (:$*CWD), (CWD => $*CWD), 'Adverb with $* twigil works';
    is-deeply (:@*ARGS), (ARGS => @*ARGS), 'Adverb with @* twigil works';
    is-deeply (:%*ENV), (ENV => %*ENV), 'Adverb with %* twigil works';
    is-deeply ({ :$^f }(3)), (f => 3), 'Adverb with $^ twigil works';
    is-deeply ({ :@^f }([3,3])), (f => [3,3]), 'Adverb with @^ twigil works';
    is-deeply ({ :%^f }((:a(3)))), (f => :a(3)), 'Adverb with %^ twigil works';
    is-deeply ({ :$:f }(:f(3))), (f => 3), 'Adverb with $: twigil works';
    is-deeply ({ :@:f }(:f(3,3))), (f => (3,3)), 'Adverb with @: twigil works';
    is-deeply ({ :%:f }(:f(:a<3>))), (f => :a<3>), 'Adverb with %: twigil works';
    # Not using sigils in rx due to RT #121061 but we do not need to for this
    "aaaa" ~~ m/$<fee>=a $<fie>=((a)(a)) $<foe>=($<fum>=(a))/;
    is-deeply (:$<fee>), (fee => $<fee>), 'Adverb with $< twigil works';
    #?rakudo 2 todo ":@<...> and :%<...> broken needs RT"
    is-deeply (:@<fie>), (fie => @<fie>), 'Adverb with @< twigil works';
    is-deeply (:%<foe>), (foe => %<foe>), 'Adverb with %< twigil works';
    is-deeply (:$~MAIN), (MAIN => $~MAIN), 'Adverb with $~ twigil works';
    is-deeply (:@~MAIN), (MAIN => @~MAIN), 'Adverb with @~ twigil works';
    is-deeply (:%~MAIN), (MAIN => %~MAIN), 'Adverb with %~ twigil works';

} # 30

# These tests are not exaustive, due to the sheer combinatorics involved.
# Hopefully they are diverse enough to catch a lot of possible issues.

is {:b :a(42)}, {:b, :a(42)}, '{:b, :a(42)} is same with all commas';
is {:e(42, 43), :c{"foo" => 42}:d["foo"]}, {:e(42, 43), :c{"foo" => 42}, :d["foo"]}, '{:e(42, 43), :c{"foo" => 42}:d["foo"]} is same with all commas';
is {:g["foo", "bar"], :f<foo> :i<foo bar> :j}, {:g["foo", "bar"], :f<foo> , :i<foo bar> , :j}, '{:g["foo", "bar"], :f<foo> :i<foo bar> :j} is same with all commas';
is {:h(42) :k(42, 43)}, {:h(42) , :k(42, 43)}, '{:h(42) :k(42, 43)} is same with all commas';
is {:b{"foo" => 42} :a["foo"], :e["foo", "bar"]}, {:b{"foo" => 42} , :a["foo"], :e["foo", "bar"]}, '{:b{"foo" => 42} :a["foo"], :e["foo", "bar"]} is same with all commas';
is {:c<foo>:d<foo bar>, :g :f(42)}, {:c<foo>, :d<foo bar>, :g , :f(42)}, '{:c<foo>:d<foo bar>, :g :f(42)} is same with all commas';
is {:i(42, 43) :j{"foo" => 42}, :h["foo"] :k["foo", "bar"]:b<foo>}, {:i(42, 43) , :j{"foo" => 42}, :h["foo"] , :k["foo", "bar"], :b<foo>}, '{:i(42, 43) :j{"foo" => 42}, :h["foo"] :k["foo", "bar"]:b<foo>} is same with all commas';
is {:a<foo bar> :e:c(42), :d(42, 43)}, {:a<foo bar> , :e, :c(42), :d(42, 43)}, '{:a<foo bar> :e:c(42), :d(42, 43)} is same with all commas';
is {:g{"foo" => 42}:f["foo"] :i["foo", "bar"], :j<foo> :h<foo bar>}, {:g{"foo" => 42}, :f["foo"] , :i["foo", "bar"], :j<foo> , :h<foo bar>}, '{:g{"foo" => 42}:f["foo"] :i["foo", "bar"], :j<foo> :h<foo bar>} is same with all commas';
is {:k :b(42) :a(42, 43), :e{"foo" => 42}:c["foo"] :d["foo", "bar"]}, {:k , :b(42) , :a(42, 43), :e{"foo" => 42}, :c["foo"] , :d["foo", "bar"]}, '{:k :b(42) :a(42, 43), :e{"foo" => 42}:c["foo"] :d["foo", "bar"]} is same with all commas';
is {:g<foo> :f<foo bar>, :i:j(42), :h(42, 43)}, {:g<foo> , :f<foo bar>, :i, :j(42), :h(42, 43)}, '{:g<foo> :f<foo bar>, :i:j(42), :h(42, 43)} is same with all commas';
is {:k{"foo" => 42}:b["foo"], :a["foo", "bar"] :e<foo>, :c<foo bar> :d}, {:k{"foo" => 42}, :b["foo"], :a["foo", "bar"] , :e<foo>, :c<foo bar> , :d}, '{:k{"foo" => 42}:b["foo"], :a["foo", "bar"] :e<foo>, :c<foo bar> :d} is same with all commas';
is {:g(42) :f(42, 43), :i{"foo" => 42} :j["foo"], :h["foo", "bar"]:k<foo> :b<foo bar>}, {:g(42) , :f(42, 43), :i{"foo" => 42} , :j["foo"], :h["foo", "bar"], :k<foo> , :b<foo bar>}, '{:g(42) :f(42, 43), :i{"foo" => 42} :j["foo"], :h["foo", "bar"]:k<foo> :b<foo bar>} is same with all commas';
is (:c{"foo" => 42} :d["foo"]), (:c{"foo" => 42}, :d["foo"]), '(:c{"foo" => 42}, :d["foo"]) is same with all commas';
is (:g["foo", "bar"], :f<foo>:i<foo bar>), (:g["foo", "bar"], :f<foo>, :i<foo bar>), '(:g["foo", "bar"], :f<foo>:i<foo bar>) is same with all commas';
is (:j, :h(42) :k(42, 43) :b{"foo" => 42}), (:j, :h(42) , :k(42, 43) , :b{"foo" => 42}), '(:j, :h(42) :k(42, 43) :b{"foo" => 42}) is same with all commas';
is (:a["foo"] :e["foo", "bar"]), (:a["foo"] , :e["foo", "bar"]), '(:a["foo"] :e["foo", "bar"]) is same with all commas';
is (:c<foo> :d<foo bar>, :g), (:c<foo> , :d<foo bar>, :g), '(:c<foo> :d<foo bar>, :g) is same with all commas';
is (:f(42):i(42, 43), :j{"foo" => 42} :h["foo"]), (:f(42), :i(42, 43), :j{"foo" => 42} , :h["foo"]), '(:f(42):i(42, 43), :j{"foo" => 42} :h["foo"]) is same with all commas';
is (:k["foo", "bar"] :b<foo>, :a<foo bar> :e:c(42)), (:k["foo", "bar"] , :b<foo>, :a<foo bar> , :e, :c(42)), '(:k["foo", "bar"] :b<foo>, :a<foo bar> :e:c(42)) is same with all commas';
is (:d(42, 43) :g{"foo" => 42}:f["foo"], :i["foo", "bar"]), (:d(42, 43) , :g{"foo" => 42}, :f["foo"], :i["foo", "bar"]), '(:d(42, 43) :g{"foo" => 42}:f["foo"], :i["foo", "bar"]) is same with all commas';
is (:j<foo>:h<foo bar> :k, :b(42) :a(42, 43)), (:j<foo>, :h<foo bar> , :k, :b(42) , :a(42, 43)), '(:j<foo>:h<foo bar> :k, :b(42) :a(42, 43)) is same with all commas';
is (:e{"foo" => 42} :c["foo"] :d["foo", "bar"], :g<foo>:f<foo bar> :i), (:e{"foo" => 42} , :c["foo"] , :d["foo", "bar"], :g<foo>, :f<foo bar> , :i), '(:e{"foo" => 42} :c["foo"] :d["foo", "bar"], :g<foo>:f<foo bar> :i) is same with all commas';
is (:j(42) :h(42, 43), :k{"foo" => 42}:b["foo"], :a["foo", "bar"]), (:j(42) , :h(42, 43), :k{"foo" => 42}, :b["foo"], :a["foo", "bar"]), '(:j(42) :h(42, 43), :k{"foo" => 42}:b["foo"], :a["foo", "bar"]) is same with all commas';
is (:e<foo>:c<foo bar>, :d :g(42), :f(42, 43) :i{"foo" => 42}), (:e<foo>, :c<foo bar>, :d , :g(42), :f(42, 43) , :i{"foo" => 42}), '(:e<foo>:c<foo bar>, :d :g(42), :f(42, 43) :i{"foo" => 42}) is same with all commas';
is (:j["foo"] :h["foo", "bar"], :k<foo> :b<foo bar>, :a:e(42) :c(42, 43)), (:j["foo"] , :h["foo", "bar"], :k<foo> , :b<foo bar>, :a, :e(42) , :c(42, 43)), '(:j["foo"] :h["foo", "bar"], :k<foo> :b<foo bar>, :a:e(42) :c(42, 43)) is same with all commas';
is (:d{"foo" => 42}, :g["foo"] :f["foo", "bar"]; :i<foo>), (:d{"foo" => 42}, :g["foo"] , :f["foo", "bar"]; :i<foo>), '(:d{"foo" => 42}, :g["foo"] :f["foo", "bar"]; :i<foo>) is same with all commas';
is (:j<foo bar> :h, :k(42) :b(42, 43); :a{"foo" => 42} :e["foo"]), (:j<foo bar> , :h, :k(42) , :b(42, 43); :a{"foo" => 42} , :e["foo"]), '(:j<foo bar> :h, :k(42) :b(42, 43); :a{"foo" => 42} :e["foo"]) is same with all commas';
is (:c["foo", "bar"] :d<foo>, :g<foo bar> :f :i(42); :j(42, 43), :h{"foo" => 42}), (:c["foo", "bar"] , :d<foo>, :g<foo bar> , :f , :i(42); :j(42, 43), :h{"foo" => 42}), '(:c["foo", "bar"] :d<foo>, :g<foo bar> :f :i(42); :j(42, 43), :h{"foo" => 42}) is same with all commas';
is (:k["foo"]; :b["foo", "bar"] :a<foo>, :e<foo bar>), (:k["foo"]; :b["foo", "bar"] , :a<foo>, :e<foo bar>), '(:k["foo"]; :b["foo", "bar"] :a<foo>, :e<foo bar>) is same with all commas';
is (:c :d(42), :g(42, 43); :f{"foo" => 42} :i["foo"], :j["foo", "bar"] :h<foo>), (:c , :d(42), :g(42, 43); :f{"foo" => 42} , :i["foo"], :j["foo", "bar"] , :h<foo>), '(:c :d(42), :g(42, 43); :f{"foo" => 42} :i["foo"], :j["foo", "bar"] :h<foo>) is same with all commas';
is (:k<foo bar> :b :a(42), :e(42, 43); :c{"foo" => 42} ; :d["foo"] :g["foo", "bar"]), (:k<foo bar> , :b , :a(42), :e(42, 43); :c{"foo" => 42} ; :d["foo"] , :g["foo", "bar"]), '(:k<foo bar> :b :a(42), :e(42, 43); :c{"foo" => 42} ; :d["foo"] :g["foo", "bar"]) is same with all commas';
is [:f<foo> :i<foo bar>], [:f<foo>, :i<foo bar>], '[:f<foo>, :i<foo bar>] is same with all commas';
is [:j, :h(42):k(42, 43)], [:j, :h(42), :k(42, 43)], '[:j, :h(42):k(42, 43)] is same with all commas';
is [:b{"foo" => 42}, :a["foo"] :e["foo", "bar"] :c<foo>], [:b{"foo" => 42}, :a["foo"] , :e["foo", "bar"] , :c<foo>], '[:b{"foo" => 42}, :a["foo"] :e["foo", "bar"] :c<foo>] is same with all commas';
is [:d<foo bar> :g], [:d<foo bar> , :g], '[:d<foo bar> :g] is same with all commas';
is [:f(42) :i(42, 43), :j{"foo" => 42}], [:f(42) , :i(42, 43), :j{"foo" => 42}], '[:f(42) :i(42, 43), :j{"foo" => 42}] is same with all commas';
is [:h["foo"]:k["foo", "bar"], :b<foo> :a<foo bar>], [:h["foo"], :k["foo", "bar"], :b<foo> , :a<foo bar>], '[:h["foo"]:k["foo", "bar"], :b<foo> :a<foo bar>] is same with all commas';
is [:e :c(42), :d(42, 43) :g{"foo" => 42}:f["foo"]], [:e , :c(42), :d(42, 43) , :g{"foo" => 42}, :f["foo"]], '[:e :c(42), :d(42, 43) :g{"foo" => 42}:f["foo"]] is same with all commas';
is [:i["foo", "bar"] :j<foo>:h<foo bar>, :k], [:i["foo", "bar"] , :j<foo>, :h<foo bar>, :k], '[:i["foo", "bar"] :j<foo>:h<foo bar>, :k] is same with all commas';
is [:b(42):a(42, 43) :e{"foo" => 42}, :c["foo"] :d["foo", "bar"]], [:b(42), :a(42, 43) , :e{"foo" => 42}, :c["foo"] , :d["foo", "bar"]], '[:b(42):a(42, 43) :e{"foo" => 42}, :c["foo"] :d["foo", "bar"]] is same with all commas';
is [:g<foo> :f<foo bar> :i, :j(42):h(42, 43) :k{"foo" => 42}], [:g<foo> , :f<foo bar> , :i, :j(42), :h(42, 43) , :k{"foo" => 42}], '[:g<foo> :f<foo bar> :i, :j(42):h(42, 43) :k{"foo" => 42}] is same with all commas';
is [:b["foo"] :a["foo", "bar"], :e<foo>:c<foo bar>, :d], [:b["foo"] , :a["foo", "bar"], :e<foo>, :c<foo bar>, :d], '[:b["foo"] :a["foo", "bar"], :e<foo>:c<foo bar>, :d] is same with all commas';
is [:g(42):f(42, 43), :i{"foo" => 42} :j["foo"], :h["foo", "bar"] :k<foo>], [:g(42), :f(42, 43), :i{"foo" => 42} , :j["foo"], :h["foo", "bar"] , :k<foo>], '[:g(42):f(42, 43), :i{"foo" => 42} :j["foo"], :h["foo", "bar"] :k<foo>] is same with all commas';
is [:b<foo bar> :a, :e(42) :c(42, 43), :d{"foo" => 42}:g["foo"] :f["foo", "bar"]], [:b<foo bar> , :a, :e(42) , :c(42, 43), :d{"foo" => 42}, :g["foo"] , :f["foo", "bar"]], '[:b<foo bar> :a, :e(42) :c(42, 43), :d{"foo" => 42}:g["foo"] :f["foo", "bar"]] is same with all commas';
is [:i<foo>, :j<foo bar> :h; :k(42)], [:i<foo>, :j<foo bar> , :h; :k(42)], '[:i<foo>, :j<foo bar> :h; :k(42)] is same with all commas';
is [:b(42, 43) :a{"foo" => 42}, :e["foo"] :c["foo", "bar"]; :d<foo> :g<foo bar>], [:b(42, 43) , :a{"foo" => 42}, :e["foo"] , :c["foo", "bar"]; :d<foo> , :g<foo bar>], '[:b(42, 43) :a{"foo" => 42}, :e["foo"] :c["foo", "bar"]; :d<foo> :g<foo bar>] is same with all commas';
is [:f :i(42), :j(42, 43) :h{"foo" => 42} :k["foo"]; :b["foo", "bar"], :a<foo>], [:f , :i(42), :j(42, 43) , :h{"foo" => 42} , :k["foo"]; :b["foo", "bar"], :a<foo>], '[:f :i(42), :j(42, 43) :h{"foo" => 42} :k["foo"]; :b["foo", "bar"], :a<foo>] is same with all commas';
is [:e<foo bar>; :c :d(42), :g(42, 43)], [:e<foo bar>; :c , :d(42), :g(42, 43)], '[:e<foo bar>; :c :d(42), :g(42, 43)] is same with all commas';
is [:f{"foo" => 42} :i["foo"], :j["foo", "bar"]; :h<foo> :k<foo bar>, :b :a(42)], [:f{"foo" => 42} , :i["foo"], :j["foo", "bar"]; :h<foo> , :k<foo bar>, :b , :a(42)], '[:f{"foo" => 42} :i["foo"], :j["foo", "bar"]; :h<foo> :k<foo bar>, :b :a(42)] is same with all commas';
is [:e(42, 43) :c{"foo" => 42} :d["foo"], :g["foo", "bar"]; :f<foo> ; :i<foo bar> :j], [:e(42, 43) , :c{"foo" => 42} , :d["foo"], :g["foo", "bar"]; :f<foo> ; :i<foo bar> , :j], '[:e(42, 43) :c{"foo" => 42} :d["foo"], :g["foo", "bar"]; :f<foo> ; :i<foo bar> :j] is same with all commas';



# RT #74492
{
    sub foo(:$a, :$b, :$c) {
        ok $a && $b && $c, "Adverbs without punctuations is allowed"
    }
    foo(:a :b :c);
    foo(:a:b:c);
}

# RT #117739
{
    is-deeply (:99999999999999999999999dd),
              (dd => 99999999999999999999999),
              "Large numeric adverbs don't error out, and also give the correct value";
}

# RT #127023
{
    is (:w :h<1>), (w => True, h => val("1")), 'IntStr adverb value in colonlist';
}