#!/bin/bash
# wallhaven_bulk_dl.sh
# Description :
# This bash script is using Wallhaven.com's v1 API to search for and download
# wallpapers based on the options provided.
# Please note that the API is limited to 45 request per minutes.

VERSION="13.03.2021"

# possible values for options
sortoptions="date_added,relevance,random,views,favorites"
topRanges="1d,3d,1w,1M,3M,6M,1y"

help() {
    echo "$0 -- Version: $VERSION"
    echo "This bash script is using wallhaven.cc's v1 API to search for and "
    echo "download wallpapers based on the arguments provided."
    echo "Please note that this API is limited to 45 request per minutes."
    echo ""
    echo "options:"
    echo "-q | --query <arg>            Search term."
    echo "-s | --sort  <sorting_option> Sorting used."
    echo "      $sortoptions"
    echo "-t | --toplist <time_range>   Toplist sorting offers time ranges :"
    echo "      $topRanges"
    echo "-p | --pages <number>         Number of pages to dowload."
    echo "-o | --output-directory <dir> Change the default output directory."
    echo "-f | --favorites              Choose tag from favorites."
    echo "-h | --help                   Print this help."
}

if [[ $# -lt 1 ]]; then
    help
    exit 1
fi

# Favorite tags file
configdir="$HOME/.config/wallhaven_bulk_dl/"
! [ -d "$configdir" ] && mkdir -p "$configdir"
[ -f "$configdir/tags" ] && tags="$configdir/tags"
tmpdir="$(mktemp -d)"
walldir="$(xdg-user-dir PICTURES)/wallpapers/"

# default values for options
search_query=""
sorting="date_added"
range="1M"
pages=5

# getopt options to parse
OPTIONS="q:s:t:p:o:fh"
LONGOPTS="query:,sort:,toplist:,pages:,output-directory:,favorites,help"
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")

if [[ ${PIPED_STATUS[0]} -ne 0 ]]; then
    exit 2
fi
eval set -- "$PARSED"
while true; do
    case "$1" in
        -q|--query)
            search_query="$(echo $2| sed 's/ /+/g'|sed 's/#//g')"
            shift 2
            ;;
        -s|--sort)
            if echo $sortoptions| grep -w "$2" >/dev/null;  then
                sorting="$2"
            else
                echo "Bad sorting option : $2"
                exit 1
            fi
            shift 2
            ;;
        -t|--toplist)
            if echo $topRanges| grep -w "$2" >/dev/null;  then
                sorting="toplist"
                range="$2"
            else
                echo "Bad time range option : $2"
                exit 1
            fi
            shift 2
            ;;
        -p|--pages)
            pages=$2
            shift 2
            ;;
        -o|--output-directory)
            walldir="$2"
            shift 2
            ;;
        -f|--favorites)
            search_query="$(cat $tags| fzf| sed 's/ /+/g; s/#//')"
            shift
            ;;
        -h|--help)
            help
            exit
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Programming Error"
            exit 3
            ;;
    esac
done

godspeed='Y'
if [[ $pages -gt 45 ]]; then
    echo "Warning : if you have godspeed internet you'll be blocked by the api."
    echo "Do you want to continue ? [Y/n]: "
    read -r godspeed
    if [ "$godspeed" != 'y' ] && [ "$godspeed" != 'Y' ]; then
        exit 1
    fi
fi

# API URL
url="https://wallhaven.cc/api/v1/search"
# PARAMETERS
url+="?q=$search_query"
url+="&atleast=1920x1080"
url+="&sorting=$sorting"
if [[ $sorting = "toplist"  ]]; then
    url+="&topRange=$range"
fi

for page in $(seq 1 "$pages" ); do
    notify-send "Downloading $page out of $pages pages."
    api_request=$(curl -s "${url}&page=${page}") # json formatted output
    parsed_urls=$(echo $api_request| jq '.data[] | .path' | tr -d '"')
    wget -nv -nc $parsed_urls -P $tmpdir
done

notify-send "Download Finished !"

sxiv -t "$tmpdir"/* 2>/dev/null
mv "$tmpdir"/* "$walldir"
rmdir "$tmpdir"
