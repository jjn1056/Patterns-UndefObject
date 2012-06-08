package Patterns::UndefObject;

use Moo;
use Sub::Exporter -setup => {
  exports => [ Maybe => \'_export_maybe' ],
};

use overload
  'bool' => sub { 0 },
  '!' => sub { 1 },
  'nomethod' => sub { die "Only boolean context is permitted" },
  'fallback' => 0;

sub AUTOLOAD { shift }

sub maybe {
  my ($class, $obj) = @_;
  return defined $obj ? $obj :
    $class->new;
}

sub _export_maybe {
  my $class = shift;
  return sub {
    $class->maybe(@_);
  }
}

1;
