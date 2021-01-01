use v6;

use Test;

use GSSDP::Raw::Types;

use GLib::MainLoop;
use GLib::Source;
use GLib::Timeout;
use GIO::InetAddress;
use GIO::InetSocketAddress;
use GIO::Socket;
use GSSDP::Client;
use GSSDP::ResourceBrowser;
use GSSDP::ResourceGroup;

constant UUID_1 is export = 'uuid:81909e94-ebf4-469e-ac68-81f2f189de1b';
constant USN    is export = 'urn:org-gupnp:device:RegressionTest673150:2';
constant USN_1  is export = 'urn:org-gupnp:device:RegressionTest673150:1';
constant NT_1   is export = "{ UUID_1 }::{ USN_1 }";

sub get-client {
  state $device = Str;

  once {
    say 'Detecting network interface to use for tests...';
    my $client = GSSDP::Client.new($device = 'lo');
    if $ERROR {
      my $client = GSSDP::Client.new($device = 'lo0');
      if $ERROR {
        say 'Using default interface, expect fails';
        return;
      }
    }
    say "Using '$device'...";
  }
  GSSDP::Client.new($device);
}

sub create-socket {
  my $socket = GIO::Socket.new;
  nok $ERROR, 'No error detected creating socket';

  my $address   = GIO::InetAddress.new-from-string('127.0.0.1');
  my $sock-addr = GIO::InetSocketAddress.new($address);
  $socket.bind($sock-addr, True);
  nok $ERROR, 'No error detected creating socket';

  .unref for $sock-addr, $address;
  $socket;
}

sub create-alive-message ($nt, $max-life) {
  build-alive-message(
    age      => $max-life,
    location => 'http://127.0.0.1:1234',
    server   => 'Linux/3.0 UPnP/1.0 GSSDPTesting/0.0.0',
    usn      => $nt eq UUID_1 ?? UUID_1 !! "{ UUID_1 }::$nt",
    :$nt,
  );
}

sub send-packet ($msg) {
  my $socket    = create-socket;
  my $address   = GIO::InetAddress.new-from-string(SSDP_ADDR);
  my $sock-addr = GIO::InetSocketAddress.new($address, SSDP_PORT);

  $socket.send-to($sock-addr, $msg);
  nok $ERROR, 'No error detected when sending message to socket';
  .unref for $sock-addr, $address;
  0;
}

sub test-bgo673150 {
  my $loop;
  my $dest = get-client;
  ok  $dest,           'Destination client created successfully';
  nok $ERROR,          'No errors detected during client creation';

  my $src = get-client;
  ok  $dest,           'Source client created successfully';
  nok $ERROR,          'No errors detected during client creation';

  my $group = GSSDP::ResourceGroup.new($src);
  $group.add-resource-simple(USN, UUID_1~'::'~USN, 'http://127.0.0.1/3456');
  $group.max-age = 10;

  my $browser = GSSDP::ResourceBrowser.new($dest, USN_1);
  $browser.resource-unavailable.tap({
    say 'Resource suddenly unavailable, exiting!';
    $loop.quit;
  });

  GLib::Timeout.add-seconds(5, -> *@a {
    $browser.active = True;
    ok  $browser.active, 'Resource browser is active';
    G_SOURCE_REMOVE;
  });
  $group.available = True;
  ok  $group.available,  'Resource group is available';

  $loop = GLib::MainLoop.new;
  GLib::Timeout.add-seconds(30, -> *@a { $loop.quit; G_SOURCE_REMOVE });
  $loop.run;

  #$browser.resource-unavailable.untap;
  .unref for $group, $browser, $src, $dest, $loop;
}

sub test-bgo682099 {
  my ($loop, $dest) = ( GLib::MainLoop.new, get-client() );
  ok  $dest,  'Destination client created successfully';
  nok $ERROR, 'No errors were detected during creation';

  my $browser = GSSDP::ResourceBrowser.new($dest, USN_1);
  $browser.resource-unavailable.tap(-> *@a {
    CATCH { default { .message.say; .backtrace.concise.say } }
    is @a[1], NT_1, 'Resource available event contains proper USN';
    $loop.quit;
  });
  $browser.active = True;
  GLib::Timeout.add-seconds(2, -> *@a {
    CATCH { default { .message.say; .backtrace.concise.say } }
    send-packet( create-alive-message(USN_1, 5) );
    G_SOURCE_REMOVE;
  });
  $loop.run;

  $browser.resource-unavailable.tap(:replace, -> *@a {
    die 'UNEXPECTED! - Resource became unavailable!';
  });
  GLib::Source.idle-add(-> *@a {
    $browser.unref;
    G_SOURCE_REMOVE;
  });
  GLib::Timeout.add-seconds(10, -> *@a {
    $loop.quit;
    G_SOURCE_REMOVE;
  });
  $loop.run;
}

constant UUID_MISSED_BYE_BYE_1     = 'uuid:81909e94-ebf4-469e-ac68-81f2f18816ac';
constant USN_MISSED_BYE_BYE        = 'urn:org-gupnp:device:RegressionTestMissedByeBye:2';
constant USN_MISSED_BYE_BYE_1      = 'urn:org-gupnp:device:RegressionTestMissedByeBye:1';
constant NT_MISSED_BYE_BYE_1       = UUID_MISSED_BYE_BYE_1~'::'~USN_MISSED_BYE_BYE_1;
constant LOCATION_MISSED_BYE_BYE_1 = 'http://127.0.0.1:1234';
constant LOCATION_MISSED_BYE_BYE_2 = 'http://127.0.0.1:1235';

sub create-alive-message-bgo724030 ($location) {
  build-alive-message(
    :$location,
    host   => SSDP_ADDR,
    age    => 5,
    server => 'Linux/3.0 UPnP/1.0 GSSDPTesting/0.0.0',
    nt     => NT_MISSED_BYE_BYE_1,
    usn    => USN_MISSED_BYE_BYE_1
  );
}

sub test-bgo724030 {
  my $loop = GLib::MainLoop.new;
  my $dest = get-client();
  ok  $dest,  'Destination client created successfully';
  nok $ERROR, 'No errors were detected during creation';

  my $browser = GSSDP::ResourceBrowser.new($dest, USN_MISSED_BYE_BYE_1);
  $browser.resource-available.tap(-> *@a {
    my $l = GLib::GList.new( @a[2] ) but GLib::Roles::ListData[Str];
    is @a[1], USN_MISSED_BYE_BYE_1,      'USN detected at resource-available time matches proper value';
    is $l[0], LOCATION_MISSED_BYE_BYE_1, 'Location detected at resource-available time matches proper value';
    $loop.quit;
  });
  $browser.resource-unavailable.tap(-> *@a {
    is @a[1], USN_MISSED_BYE_BYE_1,      'USN detected at resource-unavailable time matches proper value';
    $loop.quit;
  });
  $browser.active = True;
  GLib::Timeout.add-seconds(2, -> *@a {
    send-packet( create-alive-message-bgo724030(LOCATION_MISSED_BYE_BYE_1) );
    G_SOURCE_REMOVE;
  });
  GLib::Timeout.add-seconds(3, -> *@a {
    send-packet( create-alive-message-bgo724030(LOCATION_MISSED_BYE_BYE_2) );
    G_SOURCE_REMOVE;
  });
  $loop.run;

  $browser.resource-unavailable.disconnect;
  $browser.resource-available.tap( -> *@a {
    my $l = GLib::GList.new( @a[2] ) but GLib::Roles::ListData[Str];
    is @a[1], USN_MISSED_BYE_BYE_1,      'USN detected at resource-available time matches proper value';
    is $l[0], LOCATION_MISSED_BYE_BYE_2, 'Location detected at resource-available time matches proper value';
    $loop.quit;
  });
  $loop.run; # Unavailable + Available
  $loop.run; # Unavailable
  $browser.unref;
}

sub test-ggo1 {
  my $loop = GLib::MainLoop.new;
  my $dest = get-client();
  ok  $dest,  'Destination client created successfully';
  nok $ERROR, 'No errors were detected during creation';
  $dest.append-header('Foo', 'bar');

  given my $group = GSSDP::ResourceGroup.new($dest) {
    ok  $_,   'Resource group created successfully';
    .add-resource-simple(
      USN,
      UUID_1~'::'~USN,
      'http://127.0.0.1:3456'
    );
    ( .max-age, .available ) = (1, True);
  }
  GLib::Timeout.add-seconds(2, -> *@a { $loop.quit; G_SOURCE_REMOVE });
  $loop.run;

  $dest.clear-headers;
  $dest.unref;
  GLib::Timeout.add-seconds(10, -> *@a { $loop.quit; G_SOURCE_REMOVE });
  $loop.run;
}

sub test-ggo7 {
  my $client = GSSDP::Client.new_initable(host-ip => '127.0.0.1');
  ok  $client, 'Initable client created successfully';
  nok $ERROR,  'No errors detected during creation';

  my $iface = $client.get-interface;
  diag "Found adapter { $iface } for 127.0.0.1";
  $client.clear_object;

  my $client2 = GSSDP::Client.new_initable(
    host-ip   => '127.0.0.1',
    interface => 'ThisShouldNotExist'
  );
  is  $ERROR.domain, gssdp_error(),          'Error domain belongs to GSSDP';
  is  $ERROR.code,   GSSDP_ERROR_FAILED.Int, 'Error code is GSSDP_ERROR_FAILED';
  nok $client2,                              'Invalid client is not defined';

  my $client3 = GSSDP::Client.new_initable(
    host-ip   => '127.0.0.1',
    interface => $iface
  );
  ok  $client,                  'Initable client with interface created successfully';
  nok $ERROR,                   'No errors detected during creation';
  ok  $client.get-address-mask, 'Client created with addres mask';
}

subtest 'BGO 673150', { test-bgo673150() }
subtest 'BGO 682099', { test-bgo682099() }
subtest 'BGO 724030', { test-bgo724030() }
subtest 'GGO 1',      { test-ggo1()      }
subtest 'GGO 7',      { test-ggo7()      }
