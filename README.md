
# wallhaven_bulk_dl.sh -- Version: 13.03.2021

##Description :

    This bash script is using Wallhaven.com's v1 API to search for and download
    wallpapers based on the arguments provided.
    Please note that the API is limited to 45 request per minutes.

## Dependencies

    jq
    xdg-user-dirs
    sxiv
    wget

## Installation

### Arch Linux
    $ sudo pacman -S --needed jq wget xdg-user-dirs sxiv wget
    $ curl -sL https://raw.githubusercontent.com/t1ld3/wallhaven_bulk_dl/master/wallhaven_bulk_dl.sh -o ~/.local/bin/wallhaven_bulk-dl.sh
    $ chmod +x ~/.local/bin/wallhaven_bulk_dl.sh
