package Patterns::UndefObject;

our $VERSION = '0.001';

use strict;
use warnings;
use Sub::Exporter -setup => {
  exports => [ Maybe => \'_export_maybe' ],
};

use overload
  'bool' => sub { 0 },
  '!' => sub { 1 },
  'fallback' => 0,
  'nomethod' => \&_err_nonbool;

sub new { bless {}, shift }

sub AUTOLOAD { shift }

sub _export_maybe {
  my $class = shift;
  return sub {
    $class->maybe(@_);
  }
}

sub maybe {
  my ($class, $obj) = @_;
  return defined $obj ? $obj :
    $class->new;
}

sub _err_nonbool { die "Only boolean context is permitted" }

1;

=head1 NAME

Patterns::UndefObject - A version of the undefined object (null object) pattern

=head1 SYNOPSIS

    use Patterns::UndefObject 'Maybe';

    my $name = Maybe($user_rs->find(100))->name
      || 'Unknown Username';


=head1 DESCRIPTION

Sometimes when you are calling methods on a object you can't be sure that a
particular call chain is going to be valid.  For example, if you are using
something like L<DBIx::Class> you might start by finding out if a given user
exists in a database and then following that user's relationships for a given
purpose:

    my $primary = $schema
      ->resultset('User')
      ->find(100)
      ->telephone_numbers
      ->primary;

However this call chain will die hard during dynamic invocation should the
method call C<find(100)> fail to find a user.  This failure would return a
value of C<undef> and then a subsequent "Can't call method 'telephone_numbers'
on an undefined value.

This often leads to writing a lot of defensive code:

    my $primary;
    if(my $user = $schema->resultset('User')) {
      $primary = $user
        ->telephone_numbers
        ->primary;
    } else {
      $primary = "Unknown Number";
    }

Of course, to be truly safe, you'll need to write defense code all the way
down the chain should the relationships not be required ones.

I believe this kind of boilerplate defensive code is time consuming and
distracting to the reader.  Its verbosity draws one's attention away from the
prime purpose of the code.  Additionally, it feels like a bit of a code smell
for good object oriented design.  L<Patterns::UndefObject> offers one possible 
approach to this issue.  This class defined a factor method L</maybe> which
accepts one argument and returns that argument if it is defined.  Otherwise, it
returns an instance of L<Patterns::UndefObject>, which defines C<AUTOLOAD> such
that no matter what method is called, it always returns itself.  This allows you
to call any arbitrary length of method chains of that initial object without
causing an exception to stop you code.

This object overloads boolean context such that when evaluated as a bool, it 
always returns false.  If you try to evaluate it in any other way, you will
get an exception.  This allows you to replace the above code sample with the
following:

    use Patterns::UndefObject;
    my $primary = Patterns::UndefObject
      ->maybe($schema->resultset('User')->find(100))
      ->telephone_numbers
      ->primary || 'Unknown Number';

You can use the available export C<Maybe> to make this a bit more concise (
particularly if you need to use it several times).

    use Patterns::UndefObject 'Maybe';
    my $primary = Maybe($schema->resultset('User')->find(100))
      ->telephone_numbers
      ->primary || 'Unknown Number';

Personally I find this pattern leads to more concise and readable code and it
also provokes deeper though about ways one can use similar techniques to better
encapulate certain types of presentation logic.

=head1 AUTHOR NOTE

Should you actually use this class?  Personally I have no problem with people
using it and asking for me to support it, however I tend to think this module
is probably more about inspiring thoughts related to object oriented code,
polymorphism, and clean separation of code.  Thanks!

=head1 METHODS

This class exposes the following public methods

=head2 maybe

    my $user = Patterns::UndefObject->maybe( $user->find(100)) || "Unknown";

Accepts a single argument which should be an object or an undefined value.  If
it is a defined object, return that object, otherwise return an instance of
L<Patterns::UndefObject>.

This is considered a class method.

=head1 EXPORTS

This class defines the following exports functions.

=head2 Maybe

    use Patterns::UndefObject 'Maybe';
    my $user = Maybe($user->find(100)) || "Unknown";

Is a function that wraps the the class method L</maybe> such as to provide a
more concise helper.

=head1 SEE ALSO

The following modules or resources may be of interest.

L<Sub::Exporter>

=head1 AUTHOR

    John Napiorkowski C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012, John Napiorkowski C<< <jjnapiork@cpan.org> >>

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
