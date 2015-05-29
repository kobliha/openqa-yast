use base "opensusebasetest";
use testapi;

#
# This should be moved to some shared library as, e.g. 'ensure_in_console'
# because some tests need to run in console and it might be already
# initialized from some previous test
#

sub run() {
    # Switch to console 4
    send_key "ctrl-alt-f4";
    assert_screen "tty4-selected", 10;

    # login as user
    assert_screen "text-login", 10;
    type_string "$username\n";
    assert_screen "password-prompt", 10;
    type_password;
    type_string "\n";
    save_screenshot;

    become_root;

    type_string "echo console:done > /dev/$testapi::serialdev\n";
    wait_serial( "console:done", 2 ) || die "Console test failed";
    save_screenshot;

    # cleanup the display
    send_key("ctrl-l");
}

1;
# vim: set sw=4 et:
