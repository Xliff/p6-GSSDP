use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GSSDP::Raw::Definitions;

unit package GSSDP::Raw::ResourceGroup;

### /usr/include/gssdp-1.2/libgssdp/gssdp-resource-group.h

sub gssdp_resource_group_add_resource (
  GSSDPResourceGroup $resource_group,
  Str                $target,
  Str                $usn,
  GList              $locations
)
  returns guint
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_add_resource_simple (
  GSSDPResourceGroup $resource_group,
  Str                $target,
  Str                $usn,
  Str                $location
)
  returns guint
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_get_available (GSSDPResourceGroup $resource_group)
  returns uint32
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_get_client (GSSDPResourceGroup $resource_group)
  returns GSSDPClient
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_get_max_age (GSSDPResourceGroup $resource_group)
  returns guint
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_get_message_delay (GSSDPResourceGroup $resource_group)
  returns guint
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_new (GSSDPClient $client)
  returns GSSDPResourceGroup
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_remove_resource (
  GSSDPResourceGroup $resource_group,
  guint              $resource_id
)
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_set_available (
  GSSDPResourceGroup $resource_group,
  gboolean           $available
)
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_set_max_age (
  GSSDPResourceGroup $resource_group,
  guint              $max_age
)
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_set_message_delay (
  GSSDPResourceGroup $resource_group,
  guint              $message_delay
)
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_group_update (
  GSSDPResourceGroup $resource_group,
  guint              $new_boot_id
)
  is native(gssdp)
  is export
{ * }
