use v6.c;

use NativeCall;

use GSSDP::Raw::Types;
use GSSDP::Raw::Client;

use GLib::MainContext;
use GLib::Value;
use GIO::InetAddress;
use GIO::InetAddressMask;

use GLib::Roles::Object;
use GSSDP::Roles::Signals::Client;

our subset GSSDPClientAncestry is export of Mu
  where GSSDPClient | GObject;

class GSSDP::Client {
  also does GLib::Roles::Object;
  also does GSSDP::Roles::Signals::Client;

  has GSSDPClient $!c;

  submethod BUILD (:$client) {
    self.setGSSDPClient($client) if $client;
  }

  method setGSSDPClient (GSSDPClientAncestry $_) {
    my $to-parent;

    $!c = do {
      when GSSDPClient {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSSDPClient, $_);
      }
    }
    self!setObject($to-parent);
  }

  # Type: gboolean
  method active is rw  {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('active', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        $gv.boolean = $val.so.Int;
        self.prop_set('active', $gv);
      }
    );
  }

  # Type: gchar
  method host-ip is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('host-ip', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn 'host-ip is a construct-only attribute'
      }
    );
  }

  # Type: gchar
  method interface is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('interface', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn 'interface is a construct-only attribute'
      }
    );
  }

  # Type: gpointer
  method main-context (:$raw = False) is rw is DEPRECATED {
    my $gv = GLib::Value.new( G_TYPE_POINTER );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('main-context', $gv)
        );

        my $o = $gv.pointer;
        return Nil unless $o;

        $o = cast(GMainContext, $o);
        return $o if $raw;

        GLib::MainContext.new($o, :!ref);
      },
      STORE => -> $,  $val is copy {
        warn 'main-context is a construct-only attribute'
      }
    );
  }

  # Type: guint
  method msearch-port is rw  {
    my $gv = GLib::Value.new( G_TYPE_UINT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('msearch-port', $gv)
        );
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        warn 'msearch-port is a construct-only attribute'
      }
    );
  }

  # Type: gchar
  method network is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('network', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        warn 'network is a construct-only attribute'
      }
    );
  }

  # Type: gchar
  method server-id is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('server-id', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('server-id', $gv);
      }
    );
  }

  # Type: guint
  method socket-ttl is rw  {
    my $gv = GLib::Value.new( G_TYPE_UINT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('socket-ttl', $gv)
        );
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        warn 'socket-ttl is a construct-only attribute'
      }
    );
  }

  # Is originally:
  # GSSDPClient, gchar, guint, gint, gpointer, gpointer --> void
  method message-received {
    self.connect-message-received($!c);
  }

  multi method new (GSSDPClientAncestry $client, :$ref = True) {
    return Nil unless $client;

    my $o = self.bless( :$client );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    GMainContext()          $context,
    Str()                   $iface,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $client = gssdp_client_new($context, $iface, $error);
    set_error($error);

    $client ?? self.bless( :$client ) !! Nil;
  }

  method new_with_port (
    Str()                   $iface,
    Int()                   $msearch_port,
    CArray[Pointer[GError]] $error
  ) {
    my guint16 $m = $msearch_port;

    clear_error;
    my $client = gssdp_client_new_with_port($iface, $m, $error);
    set_error($error);

    $client ?? self.bless( :$client ) !! Nil;
  }

  method add_cache_entry (Str() $ip_address, Str() $user_agent) {
    gssdp_client_add_cache_entry($!c, $ip_address, $user_agent);
  }

  method append_header (Str() $name, Str() $value) {
    gssdp_client_append_header($!c, $name, $value);
  }

  method clear_headers {
    gssdp_client_clear_headers($!c);
  }

  method get_active {
    so gssdp_client_get_active($!c);
  }

  method get_address (:$raw = False) {
    my $a = gssdp_client_get_address($!c);

    $a ??
      ( $raw ?? $a !! GIO::InetAddress.new($a, :!ref) )
      !!
      Nil;
  }

  method get_address_mask (:$raw = False) {
    my $mask = gssdp_client_get_address_mask($!c);

    $mask ??
      ( $raw ?? $mask !! GIO::InetAddressMask.new($mask, :!ref) )
      !!
      Nil;
  }

  method get_family {
    GSocketFamily( gssdp_client_get_family($!c) );
  }

  method get_host_ip {
    gssdp_client_get_host_ip($!c);
  }

  method get_index {
    gssdp_client_get_index($!c);
  }

  method get_interface {
    gssdp_client_get_interface($!c);
  }

  method get_network {
    gssdp_client_get_network($!c);
  }

  method get_server_id {
    gssdp_client_get_server_id($!c);
  }

  method get_uda_version {
    GSSDPUDAVersionEnum( gssdp_client_get_uda_version($!c) );
  }

  method guess_user_agent (Str() $ip_address) {
    gssdp_client_guess_user_agent($!c, $ip_address);
  }

  method remove_header (Str() $name) {
    gssdp_client_remove_header($!c, $name);
  }

  method set_boot_id (Int() $boot_id) {
    my gint32 $b = $boot_id;

    gssdp_client_set_boot_id($!c, $boot_id);
  }

  method set_config_id (Int() $config_id) {
    my gint32 $c = $config_id;

    gssdp_client_set_config_id($!c, $config_id);
  }

  method set_network (Str() $network) {
    gssdp_client_set_network($!c, $network);
  }

  method set_server_id (Str() $server_id) {
    gssdp_client_set_server_id($!c, $server_id);
  }

}
