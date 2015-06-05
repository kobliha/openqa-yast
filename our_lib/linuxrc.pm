package linuxrc;
use base "opensusebasetest";
use testapi;

sub wait_for_bootmenu() {
    my $self = shift;

    assert_screen "boot-menu", 30;
    send_key "f12";
    wait_still_screen 2;

    my $dvd_found = 0;

    for my $try (1..10) {
        my $tag = "boot-menu-boot-device-".$try."-dvd";

        if (check_screen($tag, 0)) {
            bmwqemu::diag "DVD found at position ".$try.", tag: ".$tag;
            $dvd_found = $try;
            type_string $try;
            last;
        }
    }

    unless ($dvd_found) {
        save_screenshot;
        die "Cannot find DVD in boot-menu";
    }

    assert_screen("inst-bootmenu", 30);
    $self->bootmenu_down_to("inst-oninstallation");
}

sub reboot() {
    my $self = shift;

    $self->key_round("linuxrc-main-menu", "esc", 16);
    $self->key_round("linuxrc-main-menu-exit-or-reboot", "down", 8);
    $self->key_round("linuxrc-reboot-now", "ret", 4);

    # Confirm rebooting
    send_key "ret", 0;
}

sub boot_with_options {
    my $self = shift;
    my $options = shift;

    type_string $options;
    save_screenshot;

    send_key "ret";
}

1;
# vim: set sw=4 et:
