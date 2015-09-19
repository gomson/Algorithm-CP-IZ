use strict;
use warnings;

use Test::More tests => 46;
BEGIN { use_ok('Algorithm::CP::IZ') };

# create(min, max)
my $iz = Algorithm::CP::IZ->new();
my $v = $iz->create_int(0, 10);

# nb_elements
is($v->nb_elements, 11);

# domain
{
  my $dom = $v->domain;
  is(@$dom, 11);
  for my $i (0..9) {
    is($dom->[$i], $i);
  }
}

my $vdom = $iz->create_int([2, 4, 6, 8, 10], "vdom");
is(join(",", @{$vdom->domain}), "2,4,6,8,10");

my $cvar1 = $iz->create_int(33);
is($cvar1->value, 33);
my $cvar2 = $iz->create_int(33);
is($cvar2->value, 33);
is("$cvar1", "33");
is("$vdom", "vdom: {2, 4, 6, 8, 10}");
is("$v", "{0..10}");
{
    $iz->save_context;
    $v->Neq(5);
    is("$v", "{0..4, 6..10}");
    $iz->restore_context;
}

is($vdom->get_next_value(4), 6);
is($vdom->get_previous_value(10), 8);

is($vdom->is_in(8), 1);
is($vdom->is_in(7), 0);

# Neq
{
  $iz->save_context;

  $v->Neq(5);
  is(join(",", @{$v->domain}), "0,1,2,3,4,6,7,8,9,10");
  $iz->restore_context;

  my $v2 = $iz->create_int(0, 0);

  $iz->save_context;

  $v->Neq($v2);
  is(join(",", @{$v->domain}), "1,2,3,4,5,6,7,8,9,10");
  $iz->restore_context;
}

# Le
{
  $iz->save_context;
  is($v->Le(5), 1);
  is(join(",", @{$v->domain}), "0,1,2,3,4,5");
  $iz->restore_context;

  my $v2 = $iz->create_int(8, 8);

  $iz->save_context;
  is($v->Le($v2), 1);
  is(join(",", @{$v->domain}), "0,1,2,3,4,5,6,7,8");
  $iz->restore_context;

  $iz->save_context;
  is($v->Le(-1), 0);
  $iz->restore_context;
}

# Lt
{
  $iz->save_context;
  is($v->Lt(5), 1);
  is(join(",", @{$v->domain}), "0,1,2,3,4");
  $iz->restore_context;

  my $v2 = $iz->create_int(8, 8);

  $iz->save_context;
  is($v->Lt($v2), 1);
  is(join(",", @{$v->domain}), "0,1,2,3,4,5,6,7");
  $iz->restore_context;

  $iz->save_context;
  is($v->Lt(0), 0);
  $iz->restore_context;
}

# Ge
{
  $iz->save_context;
  is($v->Ge(5), 1);
  is(join(",", @{$v->domain}), "5,6,7,8,9,10");
  $iz->restore_context;

  my $v2 = $iz->create_int(8, 8);

  $iz->save_context;
  is($v->Ge($v2), 1);
  is(join(",", @{$v->domain}), "8,9,10");
  $iz->restore_context;

  $iz->save_context;
  is($v->Ge(11), 0);
  $iz->restore_context;
}

# Gt
{
  $iz->save_context;
  is($v->Gt(5), 1);
  is(join(",", @{$v->domain}), "6,7,8,9,10");
  $iz->restore_context;

  my $v2 = $iz->create_int(8, 8);

  $iz->save_context;
  is($v->Gt($v2), 1);
  is(join(",", @{$v->domain}), "9,10");
  $iz->restore_context;

  $iz->save_context;
  is($v->Gt(10), 0);
  $iz->restore_context;
}

my $v2 = $iz->create_int(-40, -2, "test");

print STDERR "name: ", $v2->name, "\n";

Algorithm::CP::IZ::RefVarArray->new([$v, $v2]);
use Data::Dumper;
print STDERR Dumper($v), Dumper($v2);


$iz->restore_all;
print STDERR "v: ", $v->min, "-", $v->max, "\n";
