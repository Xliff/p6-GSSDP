use v6.c;

use GLib::Raw::Definitions;

unit package GSSDP::Raw::Definitions;

# Forced recompile constant
constant forced = 0;

# GSSDP
constant gssdp               is export = 'gssdp-1.2',v0;

constant GSSDP_ALL_RESOURCES is export = 'ssdp:all';

# Opaques
class GSSDPClient          is repr<CPointer> does GLib::Roles::Pointers is export { }
class GSSDPResourceBrowser is repr<CPointer> does GLib::Roles::Pointers is export { }
class GSSDPResourceGroup   is repr<CPointer> does GLib::Roles::Pointers is export { }

# Enums
constant GSSDPError is export := guint32;
our enum GSSDPErrorEnum is export <
  GSSDP_ERROR_NO_IP_ADDRESS
  GSSDP_ERROR_FAILED
>;

constant GSSDPUDAVersion is export := guint32;
our enum GSSDPUDAVersionEnum is export <
  GSSDP_UDA_VERSION_UNSPECIFIED
  GSSDP_UDA_VERSION_1_0
  GSSDP_UDA_VERSION_1_1
>;

# Protocol Definitions

constant SSDP_ADDR              is export = '239.255.255.250';
constant SSDP_V6_LL             is export = 'FF02::C';
constant SSDP_V6_SL             is export = 'FF05::C';
constant SSDP_PORT              is export = 1900;
constant SSDP_PORT_STR          is export = '1900';

constant SSDP_DISCOVERY_REQUEST is export = qq:to/REQUEST/;
  M-SEARCH * HTTP/1.1
  Host: %s:{ SSDP_PORT_STR }
  Man: "ssdp:discover"
  ST: %s
  MX: %d
  User-Agent: %s
  REQUEST

constant SSDP_DISCOVERY_RESPONSE is export = q:to/RESPONSE/;
  HTTP/1.1 200 OK
  Location: %s
  %s
  Ext:
  USN: %s
  Server: %s
  Cache-Control: max-age=%d
  ST: %s
  Date: %s
  Content-Length: 0
  RESPONSE

constant SSDP_ALIVE_MESSAGE is export = qq:to/MESSAGE/;
  NOTIFY * HTTP/1.1
  Host: %s:{ SSDP_PORT_STR }
  Cache-Control: max-age=%d
  Location: %s
  %s
  Server: %s
  NTS: ssdp:alive
  NT: %s
  USN: %s
  MESSAGE

constant SSDP_BYEBYE_MESSAGE is export = qq:to/MESSAGE/;
  NOTIFY * HTTP/1.1
  Host: %s:{ SSDP_PORT_STR }
  NTS: ssdp:byebye
  NT: %s
  USN: %s
  MESSAGE

constant SSDP_UPDATE_MESSAGE is export = qq:to/MESSAGE/;
  NOTIFY * HTTP/1.1
  Host: %s:SSDP_PORT_STR
  Location: %s
  NT: %s
  NTS: ssdp:update
  USN: %s
  NEXTBOOTID.UPNP.ORG: %u
  MESSAGE

constant SSDP_SEARCH_METHOD   is export = 'M-SEARCH';
constant GENA_NOTIFY_METHOD   is export = 'NOTIFY';
constant SSDP_ALIVE_NTS       is export = 'ssdp:alive';
constant SSDP_BYEBYE_NTS      is export = 'ssdp:byebye';
constant SSDP_UPDATE_NTS      is export = 'ssdp:update';
constant SSDP_DEFAULT_MAX_AGE is export = 1800;
constant SSDP_DEFAULT_MX      is export = 3;
