use v6.c;

use NativeCall;

use GSSDP::Raw::Types;

role GSSDP::Roles::Signals::ResourceBrowser {
  has %!signals-rb;

  # GSSDPResourceBrowser, gchar, gpointer, gpointer
  method connect-resource-available (
    $obj,
    $signal = 'resource-available',
    &handler?
  ) {
    my $hid;
    %!signals-rb{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-resource-available($obj, $signal,
        -> $, $g1, $g2, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $g1, $g2, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-rb{$signal}[0].tap(&handler) with &handler;
    %!signals-rb{$signal}[0];
  }

  # GSSDPResourceBrowser, gchar, gpointer
  method connect-resource-unavailable (
    $obj,
    $signal = 'resource-unavailable',
    &handler?
  ) {
    my $hid;
    %!signals-rb{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-resource-unavailable($obj, $signal,
        -> $, $g, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $g, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-rb{$signal}[0].tap(&handler) with &handler;
    %!signals-rb{$signal}[0];
  }

}


# GSSDPResourceBrowser, gchar, gpointer, gpointer
sub g-connect-resource-available(
  Pointer $app,
  Str     $name,
          &handler (Pointer, Str, GList, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }

# GSSDPResourceBrowser, gchar, gpointer
sub g-connect-resource-unavailable(
  Pointer $app,
  Str     $name,
          &handler (Pointer, Str, Pointer),
  Pointer $data,
  uint32  $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
