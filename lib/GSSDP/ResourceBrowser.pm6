use v6.c;

use GSSDP::Raw::Types;
use GSSDP::Raw::ResourceBrowser;

use GLib::Value;
use GSSDP::Client;

use GLib::Roles::Object;
use GSSDP::Roles::Signals::ResourceBrowser;

our subset GSSDPResourceBrowserAncestry is export of Mu
  where GSSDPResourceBrowser | GObject;

class GSSDP::ResourceBrowser {
  also does GLib::Roles::Object;
  also does GSSDP::Roles::Signals::ResourceBrowser;

  has GSSDPResourceBrowser $!rb;

  submethod BUILD(:$browser) {
    self.setGSSDPResourceBrowser($browser) if $browser;
  }

  method setGSSDPResourceBrowser (GSSDPResourceBrowserAncestry $_) {
    my $to-parent;

    $!rb = do {
      when GSSDPResourceBrowser {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSSDPResourceBrowser, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GSSDP::Raw::Definitions::GSSDPResourceBrowser
  { $!rb }

  multi method new (GSSDPResourceBrowserAncestry $browser, :$ref = True) {
    return Nil unless $browser;

    my $o = self.bless( :$browser );
    $o.ref if $ref;
    $o;
  }
  multi method new (Str() $target) {
    my $browser = gssdp_resource_browser_new($!rb, $target);

    $browser ?? self.bless( :$browser ) !! Nil;
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
        $gv.boolean = $val;
        self.prop_set('active', $gv);
      }
    );
  }

  # Type: GSSDPClient
  method client (:$raw = False) is rw  {
    my $gv = GLib::Value.new( GSSDP::Client.get-type );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('client', $gv)
        );

        my $o = $gv.object;
        return Nil unless $o;

        $o = cast(GSSDPClient, $o);
        return $o if $raw;

        GSSDP::Client.new($o, :!ref);
      },
      STORE => -> $,  $val is copy {
        warn 'client is a construct-only attribute'
      }
    );
  }

  # Type: guint
  method mx is rw  {
    my $gv = GLib::Value.new( G_TYPE_UINT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('mx', $gv)
        );
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('mx', $gv);
      }
    );
  }

  # Type: gchar
  method target is rw  {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('target', $gv)
        );
        $gv.string;
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('target', $gv);
      }
    );
  }

  # Is originally:
  # GSSDPResourceBrowser, gchar, gpointer, gpointer --> void
  method resource-available {
    self.connect-resource-available($!rb);
  }

  # Is originally:
  # GSSDPResourceBrowser, gchar, gpointer --> void
  method resource-unavailable {
    self.connect-resource-unavailable($!rb);
  }

  method get_active {
    so gssdp_resource_browser_get_active($!rb);
  }

  method get_client (:$raw = False) {
    my $c = gssdp_resource_browser_get_client($!rb);

    $c ??
      ( $raw ?? $c !! GSSDP::Client.new($c, :!ref) )
      !!
      Nil;
  }

  method get_mx {
    gssdp_resource_browser_get_mx($!rb);
  }

  method get_target {
    gssdp_resource_browser_get_target($!rb);
  }

  method rescan {
    gssdp_resource_browser_rescan($!rb);
  }

  method set_active (Int() $active) {
    my gboolean $a = $active.so.Int;

    gssdp_resource_browser_set_active($!rb, $a);
  }

  method set_mx (Int() $mx) {
    my gushort $mmx = $mx;

    gssdp_resource_browser_set_mx($!rb, $mmx);
  }

  method set_target (Str() $target) {
    gssdp_resource_browser_set_target($!rb, $target);
  }

}
