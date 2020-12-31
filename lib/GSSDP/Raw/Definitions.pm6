use v6.c;

use GLib::Raw::Definitions;

unit package GSSDP::Raw::Definitions;

# Forced recompile constant
constant forced = 0;

# GSSDP
constant gssdp        is export  = 'gssdp-1.2',v0;

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
