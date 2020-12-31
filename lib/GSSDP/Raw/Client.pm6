use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GIO::Raw::Definitions;
use GIO::Raw::Enums;
use GIO::Raw::Structs;
use GSSDP::Raw::Definitions;

unit package GSSDP::Raw::Client;

### /usr/include/gssdp-1.2/libgssdp/gssdp-client.h

sub gssdp_client_add_cache_entry (
  GSSDPClient $client,
  Str         $ip_address,
  Str         $user_agent
)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_append_header (GSSDPClient $client, Str $name, Str $value)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_clear_headers (GSSDPClient $client)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_active (GSSDPClient $client)
  returns uint32
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_address (GSSDPClient $client)
  returns GInetAddress
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_address_mask (GSSDPClient $client)
  returns GInetAddressMask
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_family (GSSDPClient $client)
  returns GSocketFamily
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_host_ip (GSSDPClient $client)
  returns Str
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_index (GSSDPClient $client)
  returns guint
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_interface (GSSDPClient $client)
  returns Str
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_network (GSSDPClient $client)
  returns Str
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_server_id (GSSDPClient $client)
  returns Str
  is native(gssdp)
  is export
{ * }

sub gssdp_client_get_uda_version (GSSDPClient $client)
  returns GSSDPUDAVersion
  is native(gssdp)
  is export
{ * }

sub gssdp_client_guess_user_agent (GSSDPClient $client, Str $ip_address)
  returns Str
  is native(gssdp)
  is export
{ * }

sub gssdp_client_new (Str $iface, CArray[Pointer[GError]] $error)
  returns GSSDPClient
  is native(gssdp)
  is export
{ * }

sub gssdp_client_new_with_port (
  Str $iface,
  guint16 $msearch_port,
  CArray[Pointer[GError]] $error
)
  returns GSSDPClient
  is native(gssdp)
  is export
{ * }

sub gssdp_client_remove_header (GSSDPClient $client, Str $name)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_set_boot_id (GSSDPClient $client, gint32 $boot_id)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_set_config_id (GSSDPClient $client, gint32 $config_id)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_set_network (GSSDPClient $client, Str $network)
  is native(gssdp)
  is export
{ * }

sub gssdp_client_set_server_id (GSSDPClient $client, Str $server_id)
  is native(gssdp)
  is export
{ * }
