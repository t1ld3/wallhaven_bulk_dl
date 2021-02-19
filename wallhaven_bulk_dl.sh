#!/bin/bash
# possible values for options
sortoptions="date_added,relevance,random,views,favorites,toplist"
tagoptions="#fractal\n#digital art\n#science fiction\n#futuristic city\n#winter\n#lake\n#urban\n#vaporwave\n#retrowave\n#city lights\nspace"
topRanges="1d,3d,1w,1M,3M,6M,1y"
# getopt options to parse
OPTIONS="q:s:r:p:o:fh"
LONGOPTS="query:,sort:,range:,pages:,output-directory:,favorites,help"

# default values for options
search_query=""
sorting="date_added"
range="1M"
maximum_pages=5
tmpdir="$(mktemp -d)"
walldir="$(xdg-user-dir PICTURES)/wallpapers/"

PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
help() {
    echo "$0 -- Version: 19.02.2021"
    echo "This scripts lets you bulk download wallpapers from wallhaven.cc"
    echo "using its API to scrape the wallpapers links."
    echo ""
    echo "options:"
    echo "-q | --query <arg>            Search term."
    echo "-s | --sort  <sorting_option> Sorting used."
    echo "      $sortoptions"
    echo "-r | --range <time_range>     Time range to use with '--sort toplist' only"
    echo "      $topRanges"
    echo "-p | --pages <number>         Number of pages to dowload."
    echo "-o | --output-directory <dir> Change the default output directory."
    echo "-f | --favorites              Choose tag from favorites."
    echo "-h | --help                   Print this help."
}

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
        -r|--range)
            if echo $topRanges| grep -w "$2" >/dev/null;  then
                range="$2"
            else
                echo "Bad time range option : $2"
                exit 1
            fi
            shift 2
            ;;
        -p|--pages)
            maximum_pages=$2
            shift 2
            ;;
        -o|--output-directory)
            walldir="$2"
            shift 2
            ;;
        -f|--favorites)
            search_query="$(echo -e $tagoptions| fzf| sed 's/ /+/g'|sed 's/#//')"
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
if [[ $sorting = "toplist"  ]]; then
    toprange="&topRange=$range"
fi
if [[ $maximum_pages -gt 45 ]]; then
    echo "The Api blocks you if you do more than 45 request per minute"
    exit 1
fi
# url
url="https://wallhaven.cc/api/v1/search"
# parameters
search_query="?q=$search_query"
min_res="&atleast=1920x1080"
sorting="&sorting=$sorting"

notify-send "Downloading $maximum_pages pages of 24 wallpapers!"
for page in $(seq 1 $maximum_pages); do
    echo "Downloading $page out of $maximum_pages pages."
    api_request=$(curl -s "${url}${search_query}${min_res}${sorting}${toprange}&page=${page}")
    parsed_urls="$(echo $api_request| jq '.'| grep -Eoh 'https://w\.wallhaven.cc/full/.*(jpg|png)')"
    wget -q -nc $parsed_urls -P $tmpdir
done
notify-send "Download Finished !"
sxiv -t $tmpdir/*
mv $tmpdir/* $walldir
rmdir $tmpdir
