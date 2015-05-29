use base "opensusebasetest";
use strict;
use testapi;

sub run() {
    my ($self) = @_;


    assert_screen "bootloader", 15;
    send_key "ret";    # boot from hd
}

1;

# vim: set sw=4 et:
