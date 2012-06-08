use Test::Most;
use Patterns::UndefObject 'Maybe';

ok ref(my $obj = Patterns::UndefObject->new),
  "Created Object";

ok eval {  $obj->a->b->c; 1 },
  "Didn't die when calling chains of undef";

ok !$obj, 'still evals to false!';

my $undef;

ok ! eval {  $undef->a->b->c; 1 },
  "Dies as expected";

ok eval {  Maybe($undef)->d->e->f; 1 },
  "Passes!";

ok ! eval {  Maybe(1)->a->b->c; 1 },
  "Fails when not an object";

ok(
  ! (my $res = Maybe($undef)->g),
  'Failed as expected');

is Maybe($undef)->a || 'a', 'a';

done_testing;
