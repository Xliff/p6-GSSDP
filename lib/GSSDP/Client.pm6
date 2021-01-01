use v6.c;

use Method::Also;

use NativeCall;

use GSSDP::Raw::Types;
use GSSDP::Raw::Client;

use GLib::MainContext;
use GLib::Value;
use GIO::InetAddress;
use GIO::InetAddressMask;

use GLib::Roles::Object;
use GLib::Roles::Initiable;
use GSSDP::Roles::Signals::Client;

our subset GSSDPClientAncestry is export of Mu
  where GSSDPClient | GObject;

class GSSDP::Client {
  also does GLib::Roles::Object;
  also does GLib::Roles::Initable;
  also does GSSDP::Roles::Signals::Client;

  has GSSDPClient $!c is implementor;

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

  method GSSDP::Raw::Definitions::GSSDPClient
    is also<GSSDPClient>
  { $!c }

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
  method host-ip is rw  is also<host_ip> {
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
  method main-context (:$raw = False)
    is rw
    is DEPRECATED
    is also<main_context>
  {
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
  method msearch-port is rw  is also<msearch_port> {
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
  method server-id is rw  is also<server_id> {
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
  method socket-ttl is rw  is also<socket_ttl> {
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
  method message-received is also<message_received> {
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
  )
    is also<new-with-port>
  {
    my guint16 $m = $msearch_port;

    clear_error;
    my $client = gssdp_client_new_with_port($iface, $m, $error);
    set_error($error);

    $client ?? self.bless( :$client ) !! Nil;
  }

  method add_cache_entry (Str() $ip_address, Str() $user_agent)
    is also<add-cache-entry>
  {
    gssdp_client_add_cache_entry($!c, $ip_address, $user_agent);
  }

  method append_header (Str() $name, Str() $value) is also<append-header> {
    gssdp_client_append_header($!c, $name, $value);
  }

  method clear_headers is also<clear-headers> {
    gssdp_client_clear_headers($!c);
  }

  method get_active is also<get-active> {
    so gssdp_client_get_active($!c);
  }

  method get_address (:$raw = False) is also<get-address> {
    my $a = gssdp_client_get_address($!c);

    $a ??
      ( $raw ?? $a !! GIO::InetAddress.new($a, :!ref) )
      !!
      Nil;
  }

  method get_address_mask (:$raw = False) is also<get-address-mask> {
    my $mask = gssdp_client_get_address_mask($!c);

    $mask ??
      ( $raw ?? $mask !! GIO::InetAddressMask.new($mask, :!ref) )
      !!
      Nil;
  }

  method get_family is also<get-family> {
    GSocketFamily( gssdp_client_get_family($!c) );
  }

  method get_host_ip is also<get-host-ip> {
    gssdp_client_get_host_ip($!c);
  }

  method get_index is also<get-index> {
    gssdp_client_get_index($!c);
  }

  method get_interface is also<get-interface> {
    gssdp_client_get_interface($!c);
  }

  method get_network is also<get-network> {
    gssdp_client_get_network($!c);
  }

  method get_server_id is also<get-server-id> {
    gssdp_client_get_server_id($!c);
  }

  method get_uda_version is also<get-uda-version> {
    GSSDPUDAVersionEnum( gssdp_client_get_uda_version($!c) );
  }

  method guess_user_agent (Str() $ip_address) is also<guess-user-agent> {
    gssdp_client_guess_user_agent($!c, $ip_address);
  }

  method remove_header (Str() $name) is also<remove-header> {
    gssdp_client_remove_header($!c, $name);
  }

  method set_boot_id (Int() $boot_id) is also<set-boot-id> {
    my gint32 $b = $boot_id;

    gssdp_client_set_boot_id($!c, $boot_id);
  }

  method set_config_id (Int() $config_id) is also<set-config-id> {
    my gint32 $c = $config_id;

    gssdp_client_set_config_id($!c, $config_id);
  }

  method set_network (Str() $network) is also<set-network> {
    gssdp_client_set_network($!c, $network);
  }

  method set_server_id (Str() $server_id) is also<set-server-id> {
    gssdp_client_set_server_id($!c, $server_id);
  }

}
