use strict;
use base "y2logsstep";
use testapi;
use linuxrc;
use openqasystem;

sub run() {
    my $self = shift;

    $self->linuxrc::wait_for_bootmenu();

    $self->linuxrc::boot_with_options("SystemBoot=1");
    assert_screen("linuxrc-system_boot-select-a-system-to-boot", 60);

    # Press [Enter] till the last dialog for booting appears
    $self->key_round("linuxrc-system-boot-kernel-options", "ret", 8);

    # Confirm booting
    bmwqemu::diag "Booting the installed system now...";
    send_key "ret", 0;

    assert_screen("displaymanager", 60);
    openqasystem::run_in_console("shutdown -r now", 2);
}

sub test_flags() {
    return { 'important' => 1, 'fatal' => 1, 'milestone' => 1 };
}

1;

# vim: set sw=4 et:
