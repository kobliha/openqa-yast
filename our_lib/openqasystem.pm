package openqasystem;
use base "opensusebasetest";
use testapi;

sub run_in_console {
    my $command = shift;
    my $console = shift || 2;

    send_key "ctrl-alt-f".$console;
    send_key "alt-f".$console;
    assert_screen("text-login", 10);

    type_string "root\n";
    sleep 2;
    type_password;
    send_key "ret";
    sleep 1;

    save_screenshot;

    type_string $command;
    save_screenshot;
    send_key "ret";
}

1;
# vim: set sw=4 et:
