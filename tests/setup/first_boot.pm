use strict;
use base "y2logsstep";
use testapi;

sub run() {
    assert_screen("displaymanager", 60);
}

sub test_flags() {
    return { 'important' => 1, 'fatal' => 1, 'milestone' => 1 };
}

sub post_fail_hook() {
    my $self = shift;

    $self->export_logs();
}

1;

# vim: set sw=4 et:
