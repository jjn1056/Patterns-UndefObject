package Patterns::UndefObject;

use Moo;
use Sub::Exporter -setup => {
  exports => [ Maybe => \'_export_maybe' ],
};

has 'original' => (
  is=>'bare', predicate=>'has_original');

use overload 'bool' => sub { shift->has_original };

sub AUTOLOAD { shift }

sub maybe {
  my ($class, $obj) = @_;
  return defined $obj ? $obj :
    $class->new(original=>$obj);
}

sub _export_maybe {
  my $class = shift;
  return sub {
    $class->maybe(@_);
  }
}

1;
