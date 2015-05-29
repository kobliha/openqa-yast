use base "opensusebasetest";
use testapi;

our @filter_entries = (
    "Patterns",
    "Languages",
    "RPM Groups",
    "Repositories",
    "Search",
    "Installation Summary",
    "Package Classification",
);

our %filter_needles = (
    "Patterns" => "yast_sw_single-filter-patterns",
    "Languages" => "yast_sw_single-filter-languages",
    "RPM Groups" => "yast_sw_single-filter-rpm-groups",
    "Repositories" => "yast_sw_single-filter-repositories",
    "Search" => "yast_sw_single-filter-search",
    "Installation Summary" => "yast_sw_single-filter-installation-summary",
    "Package Classification" => "yast_sw_single-filter-package-classification",
);

# Selects a given filter in menu
sub select_filter($) {
    my $filter = shift;
    my ($filter_position) = grep { $filter_entries[$_] eq $filter } (0 .. @filter_entries-1);
    die "Filter '$filter' not found in (".join(", ", @filter_entries).")" unless defined $filter_position;
    bmwqemu::diag "Filter '$filter' is on position '$filter_position'";

    # Open filter menu and go to the top (current state is considered as unknown)
    send_key("alt-f", 1);
    send_key("up") for (1 .. @filter_entries-1);

    # Select the filter from menu
    send_key("down") for (1 .. $filter_position);

    # Validate if the requested filter entry is selected
    if (defined $filter_needles{$filter} && $filter_needles{$filter} ne "") {
        assert_screen($filter_needles{$filter}, 1);
    } else {
        bmwqemu::diag "Filter '$filter' does not have a needle to check";
        wait_idle 2;
        save_screenshot();
    }

    send_key("ret", 2);
}

# Searches for given string
sub search_for($) {
  my $search_string = shift;
  select_filter "Search";

  # Search Phrase field
  send_key "alt-p";
  type_string $search_string;
  send_key "ret";

  wait_still_screen(2);
}

# Selects all filter entries from menu one by one
sub try_all_filter_entries {
    foreach my $filter_entry (@filter_entries) {
        select_filter($filter_entry);
    }
}

# Refreshes all libzypp repositories using zypper
sub refresh_repositories() {
    type_string "zypper refresh && echo zypper_refresh:done > /dev/$testapi::serialdev\n";
    wait_serial("zypper_refresh:done", 120) || die "zypper_refresh failed";

    send_key("ctrl-l");
}

# This test runs in console
sub run() {
    send_key("ctrl-l");

    # Cheat a bit - refresh all repositories in advance
    # Downloading metadata and building the cache can take a lot of time
    refresh_repositories();

    # Start Yast Software Manager
    type_string "/usr/lib/YaST2/bin/y2base sw_single ncurses\n";
    wait_still_screen(10);
    assert_screen("yast_sw_single-started", 2);

    # Test searching functionality
    search_for("yast2-core");
    assert_screen("yast_sw_single-search-for-yast2-core");

    # Go through all filter entries
    try_all_filter_entries();

    # Quit without changing anything
    send_key("alt-c", 2);

    type_string "echo yast_sw_single:done > /dev/$testapi::serialdev\n";
    wait_serial("yast_sw_single:done", 2) || die "yast_sw_single test failed";

    send_key("ctrl-l", 1);
}

1;
# vim: set sw=4 et:
