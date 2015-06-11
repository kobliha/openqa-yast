use base "opensusebasetest";
use strict;
use testapi;

#
# Logs into the console and reboots the system
#
sub run() {
    my ($self) = @_;

    openqasystem::run_in_console("shutdown -r now", 2);
}

1;

# vim: set sw=4 et:
