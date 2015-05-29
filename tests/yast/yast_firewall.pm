use base "opensusebasetest";
use testapi;

# This test runs in console
sub run() {
    my @fw_menutree_needles = (
        # Start-Up
        "yast_firewall-startup",
        # Interfaces
        "yast_firewall-interfaces",
        # Allowed Services
        "yast_firewall-allowed-services",
        # Masquerading
        "yast_firewall-masquerading",
        # Broadcast
        "yast_firewall-broadcast",
        # Logging Level
        "yast_firewall-logging-level",
        # Custom Rules
        "yast_firewall-custom-rules",
    );

    send_key("ctrl-l", 1);

    # Start Yast firewall
    type_string "/usr/lib/YaST2/bin/y2base firewall ncurses\n";
    # Wait for Firewall UI to show a start-up dialog
    check_screen($fw_menutree_needles[0], 60);
    assert_screen($fw_menutree_needles[0], 1);

    # Going through all tree-menu items from top to bottom
    foreach my $i (1..6) {
        send_key("down", 0);
        send_key("ret", 1);
        assert_screen($fw_menutree_needles[$i], 2);
    }

    # Configuration Summary
    send_key("alt-n", 0);
    assert_screen("yast_firewall-summary", 5);

    # Finish/Write configuration
    send_key("alt-f", 1);

    type_string "echo yast_firewall:done > /dev/$testapi::serialdev\n";
    wait_serial("yast_firewall:done", 2) || die "yast_firewall test failed";

    send_key("ctrl-l", 1);
}

1;
# vim: set sw=4 et:
