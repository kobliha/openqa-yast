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
          $testapi::username = "linux";    # LiveCD account
          $testapi::password = "";
        }
        else {
            $testapi::username = "root";
            $testapi::password = '';
        }
    }
    # Default fallback
    else {
        $testapi::username = "bernhard";
        $testapi::password = "nots3cr3t";
    }
}

sub setup_test_env() {
    # FIXME: this is needed for ...
    my $distri = testapi::get_var("CASEDIR").'/lib/susedistribution.pm';
    require $distri;
    testapi::set_distribution(susedistribution->new());

    if (check_var("DESKTOP", "minimalx")) {
        set_var("NOAUTOLOGIN", 1);
        set_var("XDMUSED", 1);
        set_var("DM_NEEDS_USERNAME", 1);
    }
}

# FIXME: put this into shared library
sub logcurrentenv(@) {
    foreach my $k (@_) {
        my $e = get_var("$k");
        next unless defined $e;
        bmwqemu::diag("usingenv $k=$e");
    }
}

# FIXME: put this into shared library
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

logcurrentenv(qw"ADDONURL BIGTEST BTRFS CASEDIR DESKTOP HW HWSLOT LIVETEST LVM USBBOOT TEXTMODE DISTRI QEMUCPU QEMUCPUS RAIDLEVEL ENCRYPT INSTLANG QEMUVGA  UEFI DVD GNOME KDE ISO LIVECD NETBOOT NICEVIDEO PROMO QEMUVGA SPLITUSR VIDEOMODE");

# FIXME: why is this needed?
bmwqemu::save_vars();

# Bootloader test
loadtest "setup/boot.pm";

# System boots to minimal X (DESKTOP=minimalx)
loadtest "setup/first_boot.pm";

# Switch to console and login as user
loadtest "yast/console.pm";

1;
# vim: set sw=4 et:
