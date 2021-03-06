use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

use GLib::Roles::Pointers;

unit package GSSDP::Raw::Definitions;

# Forced recompile constant
constant forced = 13;

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

multi sub build-discovery-request (
  :$host            = SSDP_ADDR,
  :$st              = '',
  :$mx              = '',
  :user-agent(:$ua) = ''
)
  is export
{
  build-discovery-request($host, $st, $mx, $ua);
}
multi sub build-discovery-request ($host, $st, $mx, $ua) is export {
  sprintf(
    SSDP_DISCOVERY_REQUEST.subst("\n", "\r\n"),
    $host,
    $st,
    $mx,
    $ua
  );
}

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

multi sub build-discovery-response (
  :$location = '',
  :$data     = '',
  :$usn      = '',
  :$server   = '',
  :$age      = '',
  :$date     = ''
) is export {
  build-discovery-response(
    $location,
    $data,
    $usn,
    $server,
    $age,
    $date
  );
}
multi sub build-discovery-response (
  $location,
  $data,
  $usn,
  $server,
  $age,
  $date
) is export {
  sprintf(
    SSDP_DISCOVERY_RESPONSE.subst("\n", "\r\n"),
    $location,
    $data,
    $usn,
    $server,
    $age,
    $date
  );
}

constant SSDP_ALIVE_MESSAGE is export =
  "NOTIFY * HTTP/1.1\r\n"           ~
  "Host: %s:{ SSDP_PORT_STR }\r\n"  ~
  "Cache-Control: max-age=%d\r\n"   ~
  "Location: %s\r\n"                ~
  "%s"                              ~
  "Server: %s\r\n"                  ~
  "NTS: ssdp:alive\r\n"             ~
  "NT: %s\r\n"                      ~
  "USN: %s\r\n"                     ;

multi sub build-alive-message (
  :$host     = SSDP_ADDR,
  :$age      = '',
  :$location = '',
  :$data     = '',
  :$server   = '',
  :$nt       = '',
  :$usn      = ''
) is export {
  build-alive-message(
    $host,
    $age,
    $location,
    $data,
    $server,
    $nt,
    $usn
  );
}
multi sub build-alive-message(
  $host,
  $age,
  $location,
  $data,
  $server,
  $nt,
  $usn
) is export {
  sprintf(
    SSDP_ALIVE_MESSAGE.subst("\n", "\r\n"),
    $host,
    $age,
    $location,
    $data,
    $server,
    $nt,
    $usn
  );
}

constant SSDP_BYEBYE_MESSAGE is export = qq:to/MESSAGE/;
  NOTIFY * HTTP/1.1
  Host: %s:{ SSDP_PORT_STR }
  NTS: ssdp:byebye
  NT: %s
  USN: %s
  MESSAGE

multi sub build-byebye-message (
  :$host = SSDP_ADDR,
  :$nt   = '',
  :$usn  = ''
) is export {
  build-byebye-message($host, $nt, $usn);
}
multi sub build-byebye-message ($host, $nt, $usn) is export {
  sprintf(
    SSDP_BYEBYE_MESSAGE.subst("\n", "\r\n"),
    $host,
    $nt,
    $usn
  );
}

constant SSDP_UPDATE_MESSAGE is export = qq:to/MESSAGE/;
  NOTIFY * HTTP/1.1
  Host: %s:SSDP_PORT_STR
  Location: %s
  NT: %s
  NTS: ssdp:update
  USN: %s
  NEXTBOOTID.UPNP.ORG: %u
  MESSAGE

multi sub build-update-message (
  :$host     = SSDP_ADDR,
  :$location = '',
  :$nt       = '',
  :$usn      = '',
  :$bootid   = ''
) {
  build-update-message($host, $location, $nt, $usn, $bootid);
}
multi sub build-update-message ($host, $location, $nt, $usn, $bootid) {
  sprintf(
    SSDP_UPDATE_MESSAGE.subst("\n", "\r\n"),
    $host,
    $location,
    $nt,
    $usn,
    $bootid
  );
}

constant SSDP_SEARCH_METHOD   is export = 'M-SEARCH';
constant GENA_NOTIFY_METHOD   is export = 'NOTIFY';
constant SSDP_ALIVE_NTS       is export = 'ssdp:alive';
constant SSDP_BYEBYE_NTS      is export = 'ssdp:byebye';
constant SSDP_UPDATE_NTS      is export = 'ssdp:update';
constant SSDP_DEFAULT_MAX_AGE is export = 1800;
constant SSDP_DEFAULT_MX      is export = 3;

sub gssdp_error ()
  returns GQuark
  is export
  is symbol('gssdp_error_quark')
  is native(gssdp)
{ * }