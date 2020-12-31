use v6.c;

use NativeCall;

use GSSDP::Raw::Types;

role GSSDP::Roles::Signals::Client {
  has %!signals-c;

  # GSSDPClient, gchar, guint, gint, gpointer, gpointer
  method connect-message-received (
    $obj,
    $signal = 'message-received',
    &handler?
  ) {
    my $hid;
    %!signals-c{$signal} //= do {
      my \𝒮 = Supplier.new;
      $hid = g-connect-message-received($obj, $signal,
        -> $, $c, $u, $i, $p, $ud {
          CATCH {
            default { 𝒮.note($_) }
          }

          𝒮.emit( [self, $c, $u, $i, $p, $ud ] );
        },
        Pointer, 0
      );
      [ 𝒮.Supply, $obj, $hid ];
    };
    %!signals-c{$signal}[0].tap(&handler) with &handler;
    %!signals-c{$signal}[0];
  }

}

# GSSDPClient, gchar, guint, gint, gpointer, gpointer
sub g-connect-message-received(
  Pointer $app,
  Str $name,
  &handler (Pointer, Str, guint, gint, gpointer, Pointer),
  Pointer $data,
  uint32 $flags
)
  returns uint64
  is native(gobject)
  is symbol('g_signal_connect_object')
{ * }
