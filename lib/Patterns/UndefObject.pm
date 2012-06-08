package Patterns::UndefObject;

use Moo;
use Sub::Exporter -setup => {
  exports => [ Maybe => \'_export_maybe' ],
};

use overload
  'bool' => sub { 0 },
  '!' => sub { 1 },
  'fallback' => 0,
  'nomethod' => \&_err_nonbool;

sub _err_nonbool { die "Only boolean context is permitted" }

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

sub AUTOLOAD { shift }

1;
