use strict;
use base "y2logsstep";
use testapi;
use linuxrc;
use openqasystem;

sub run() {
    my $self = shift;

    $self->linuxrc::wait_for_bootmenu();

    $self->linuxrc::boot_with_options("AddSwap=-1");
    assert_screen("linuxrc-manual-swap", 60);
    $self->linuxrc::reboot;
}

sub test_flags() {
    return { 'important' => 1, 'fatal' => 1, 'milestone' => 1 };
}

1;

# vim: set sw=4 et:
