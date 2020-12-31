use v6.c;

use GSSDP::Raw::Types;
use GSSDP::Raw::ResourceGroup;

use GLib::Value;

use GLib::Roles::Object;

our subset GSSDPResourceGroupAncestry is export of Mu
  where GSSDPResourceGroup | GObject;

class GSSDP::ResourceGroup {
  also does GLib::Roles::Object;

  has GSSDPResourceGroup $!rg;

  submethod BUILD (:$group) {
    self.setGSSDPResourceGroup($group) if $group;
  }

  method setGSSDPResourceGroup (GSSDPResourceGroupAncestry $_) {
    my $to-parent;

    $!rg = do {
      when GSSDPResourceGroup {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GSSDPResourceGroup, $_);
      }
    }
    self!setObject($to-parent);
  }

  method GSSDP::Raw::GSSDPResourceGroup
  { $!rg }

  multi method new (GSSDPResourceGroupAncestry $group, :$ref = True) {
    return Nil unless $group;

    my $o = self.bless( :$group );
    $o.ref if $ref;
    $o;
  }
  multi method new (GSSDPClient() $client) {
    my $group = gssdp_resource_group_new($client);

    $group ?? self.bless( :$group ) !! Nil;
  }

  # Type: gboolean
  method available is rw  {
    my $gv = GLib::Value.new( G_TYPE_BOOLEAN );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('available', $gv)
        );
        $gv.boolean;
      },
      STORE => -> $, Int() $val is copy {
        $gv.boolean = $val.so.Int;
        self.prop_set('available', $gv);
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

        GSSDPClient.new($o, :!ref);
      },
      STORE => -> $,  $val is copy {
        warn 'client is a construct-only attribute'
      }
    );
  }

  # Type: guint
  method max-age is rw  {
    my $gv = GLib::Value.new( G_TYPE_UINT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('max-age', $gv)
        );
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('max-age', $gv);
      }
    );
  }

  # Type: guint
  method message-delay is rw  {
    my $gv = GLib::Value.new( G_TYPE_UINT );
    Proxy.new(
      FETCH => sub ($) {
        $gv = GLib::Value.new(
          self.prop_get('message-delay', $gv)
        );
        $gv.uint;
      },
      STORE => -> $, Int() $val is copy {
        $gv.uint = $val;
        self.prop_set('message-delay', $gv);
      }
    );
  }

  method add_resource (Str() $target, Str() $usn, GList() $locations) {
    gssdp_resource_group_add_resource($!rg, $target, $usn, $locations);
  }

  method add_resource_simple (Str() $target, Str() $usn, Str() $location) {
    gssdp_resource_group_add_resource_simple($!rg, $target, $usn, $location);
  }

  method get_available {
    so gssdp_resource_group_get_available($!rg);
  }

  method get_client (:$raw = False) {
    my $c = gssdp_resource_group_get_client($!rg);

    $c ??
      ( $raw ?? $c !! GSSDP::Client.new($c, :!ref) )
      !!
      Nil;
  }

  method get_max_age {
    gssdp_resource_group_get_max_age($!rg);
  }

  method get_message_delay {
    gssdp_resource_group_get_message_delay($!rg);
  }

  method remove_resource (Int() $resource_id) {
    my guint $r = $resource_id;

    gssdp_resource_group_remove_resource($!rg, $r);
  }

  method set_available (Int() $available) {
    my gboolean $a = $available.so.Int;

    gssdp_resource_group_set_available($!rg, $a);
  }

  method set_max_age (Int() $max_age) {
    my guint $m = $max_age;

    gssdp_resource_group_set_max_age($!rg, $m);
  }

  method set_message_delay (Int() $message_delay) {
    my guint $m = $message_delay;

    gssdp_resource_group_set_message_delay($!rg, $m);
  }

  method update (Int() $new_boot_id) {
    my guint $n = $new_boot_id;

    gssdp_resource_group_update($!rg, $n);
  }

}
