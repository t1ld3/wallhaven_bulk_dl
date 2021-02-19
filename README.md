
# wallhaven_bulk_dl.sh -- Version: 19.02.2021

    This scripts lets you bulk download wallpapers from wallhaven.cc
    using its API to scrape the wallpapers links.

    options:
    -q | --query <arg>            Search term.
    -s | --sort  <sorting_option> Sorting used.
          $sortoptions
    -r | --range <time_range>     Time range to use with '--sort toplist' only
          $topRanges
    -p | --pages <number>         Number of pages to dowload.
    -o | --output-directory <dir> Change the default output directory.
    -f | --favorites              Choose tag from favorites.
    -h | --help                   Print this help.

## Dependencies

    jq
    xdg-user-dirs
    sxiv
    wget

## Installation

### Arch Linux
    $ sudo pacman -S -needed jq wget xdg-user-dirs sxiv wget
    $ curl -sL https://raw.githubusercontent.com/t1ld3/wallhaven_bulk_dl/master/wallhaven_bulk_dl.sh -o ~/.local/bin/wallhaven_bulk-dl.sh
    $ chmod +x ~/.local/bin/wallhaven_bulk_dl.sh
