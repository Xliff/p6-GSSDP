use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GSSDP::Raw::Definitions;

unit package GSSDP::Raw::ResourceBrowser;

### /usr/include/gssdp-1.2/libgssdp/gssdp-resource-browser.h

sub gssdp_resource_browser_get_active (GSSDPResourceBrowser $resource_browser)
  returns uint32
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_get_client (GSSDPResourceBrowser $resource_browser)
  returns GSSDPClient
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_get_mx (GSSDPResourceBrowser $resource_browser)
  returns gushort
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_get_target (GSSDPResourceBrowser $resource_browser)
  returns Str
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_new (GSSDPClient $client, Str $target)
  returns GSSDPResourceBrowser
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_rescan (GSSDPResourceBrowser $resource_browser)
  returns uint32
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_set_active (
  GSSDPResourceBrowser $resource_browser,
  gboolean $active
)
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_set_mx (
  GSSDPResourceBrowser $resource_browser,
  gushort $mx
)
  is native(gssdp)
  is export
{ * }

sub gssdp_resource_browser_set_target (
  GSSDPResourceBrowser $resource_browser,
  Str $target
)
  is native(gssdp)
  is export
{ * }
