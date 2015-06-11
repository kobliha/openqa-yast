#!/usr/bin/perl -w
use strict;
use testapi;
use autotest;
use needle;
use File::Find;

#
# Started with:
#   /usr/share/openqa/script/client jobs post ARCH=x86_64 BACKEND=qemu BUILD=1 \
#     DISTRI=openqa-yast TEST=openqa-yast VERSION=Tumbleweed \
#     HDD_1=openSUSE-13.2-minimalx.qcow
#

# Sets user/pass according to test variables
# LIVETEST, USERNAME, PASSWORD, LIVECD, PROMO
#
# FIXME: put this into separate library
sub setup_user_auth {
    # User/password forced
    if (get_var("USERNAME")) {
        $testapi::username = get_var("USERNAME");
        $testapi::password = get_var("PASSWORD") if defined get_var("PASSWORD");
    }
    # Live media
    elsif (get_var("LIVETEST")) {
        if (get_var("LIVECD") || get_var("PROMO")) {
          # LiveCD account
          $testapi::username = "linux";
          $testapi::password = "";
        }
        else {
            $testapi::username = "root";
            $testapi::password = "";
        }
    }
    # Default fallback
    else {
        $testapi::username = "bernhard";
        $testapi::password = "nots3cr3t";
    }
}

sub logcurrentenv(@) {
    foreach my $k (@_) {
        my $e = get_var("$k");
        next unless defined $e;
        bmwqemu::diag("usingenv $k=$e");
    }
}

sub setup_test_env() {
    # Requires distri-specific functionality
    my $distri = testapi::get_var("CASEDIR")."/lib/susedistribution.pm";
    require $distri;

    testapi::set_distribution(susedistribution->new());

    if (check_var("DESKTOP", "minimalx")) {
        set_var("NOAUTOLOGIN", 1);
        set_var("XDMUSED", 1);
        set_var("DM_NEEDS_USERNAME", 1);
    }

    logcurrentenv(qw"ADDONURL BIGTEST BTRFS CASEDIR DESKTOP HW HWSLOT LIVETEST
                     LVM USBBOOT TEXTMODE DISTRI QEMUCPU QEMUCPUS RAIDLEVEL
                     ENCRYPT INSTLANG QEMUVGA UEFI DVD GNOME KDE ISO LIVECD
                     NETBOOT NICEVIDEO PROMO QEMUVGA SPLITUSR VIDEOMODE");
}

sub loadtest($) {
    my ($test) = @_;
    die "Unsupported test filename '$test', contains dash" if $test =~ /\-/;

    autotest::loadtest("tests/$test");
}

##
# The test starts here
##

setup_test_env();

setup_user_auth();

bmwqemu::save_vars();

#
# Test the install media / Linxurc
#

if (defined get_var("ISO")) {
    bmwqemu::diag("Testing ISO-based features");

    # Tests booting installed system using Linuxrc
    loadtest "linuxrc/system_boot.pm";

    # Reboot between tests
    loadtest "setup/reboot.pm";

    # Part of this test is also rebooting
    loadtest "linuxrc/interactive_mode.pm";
}

#
# Boot into the installed system
#

# Bootloader test
loadtest "setup/boot.pm";

# System boots to minimal X (DESKTOP=minimalx)
loadtest "setup/first_boot.pm";

#
# These test are called on running system
#

# Switch to console and login as user
loadtest "yast/console.pm";

# Run Yast Firewall test
loadtest "yast/yast_firewall.pm";

# Run Yast Package Manager test
loadtest "yast/yast_sw_single.pm";

1;
# vim: set sw=4 et:
