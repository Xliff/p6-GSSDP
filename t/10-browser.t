use v6;

use GSSDP::Raw::Types;

use GLib::MainLoop;
use GLib::GList;
use GSSDP::Client;
use GSSDP::ResourceBrowser;

use GLib::Roles::ListData;

sub MAIN {
  my $client = GSSDP::Client.new;
  die "Error creating the GSSDP client: { $ERROR.message }" if $ERROR;

  my $resource-browser = GSSDP::ResourceBrowser.new(
    $client,
    GSSDP_ALL_RESOURCES
  );

  $resource-browser.resource-available.tap(-> *@a {
    CATCH { default { .message.say; .backtrace.concise.say } }
    my $l = GLib::GList.new( @a[2] ) but GLib::Roles::ListData[Str];
    say qq:to/LIST/.chomp;
    resource available
      USN: { @a[1] }
    { $l.Array.map( '  Location: ' ~ * ).join("\n") }
    LIST
  });

  $resource-browser.resource-unavailable.tap(-> *@a {
    CATCH { default { .message.say; .backtrace.concise.say } }
    say qq:to/LIST/.chomp;
      resource unavailable
        USN: { @a[1] }
      LIST
  });

  $resource-browser.active = True;
  my $loop = GLib::MainLoop.new;
  $loop.run;

  .unref for $loop, $resource-browser, $client;
}
