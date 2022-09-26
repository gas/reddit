#!#!/usr/bin/env bash

# reddit script
# Usage default: reddit (=reddit bash 1)
# Usage: reddit 10 bash, reddit 5 commandline show, ...
# Dependencies: gum, fzf, html-xml-utils (v8+), curl

reddit() 
{
local _howmany=${2:-1} _subname=${1} _sub="https://www.reddit.com/r/${1:-bash}.rss" _dir="$HOME/.redditnews"
mkdir $_dir > /dev/null 2>&1

# 0. download index
# gum spin --spinner dot --title "Obteniendo $_howmany entradas de r/$_subname..." -- \
    curl -s -o $_dir/news_${_subname}  -A "reddit_bash_script (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15" $_sub

# 1.  headlines and exit
if [[ -z ${3} ]]; then 
    cat $_dir/news_${_subname} | asc2xml \
        | hxnormalize -x -l 150 | hxselect -s "\n" -c title \
        | tail -n +2 | head -n $_howmany

    return 1
fi

# 2.  lets get comments

# 2.1 extract links
cat $_dir/news_${_subname} | asc2xml \
    | hxnormalize -x -l 150 | hxselect -s "\n" "link[href]" \
    | sed 's/<link href="//;s/\/"><\/link>/.rss/;' | tail -n +3 \
    | head -n ${_howmany} > $_dir/links_${_subname}

# 2.2 download pages
local _x=1
# set -o pipefail
echo "Downloading ${_howmany} from ${_subname}:" > $_dir/errors_${_subname}
cat $_dir/links_${_subname} | while read line # || [[ -n $line ]];
do  
    # curl
    if gum spin --spinner dot --title " $_x/$_howmany < r/$_subname..." -- \
    curl -s -o $_dir/news_${_subname}_${_x}  \
    -A "reddit_bash_script (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15" "${line}"; then
        cat ${_dir}/news_${_subname}_${_x} \
        | xml2asc | sed 's/&#8217;/\`/g;s/&#8220;/\"/g;s/&#8221;/\"/g;' \
        | sed 's/&#8212;/-/g;' | asc2xml \
        | hxunent | hxnormalize -x -l $COLUMNS | xml2asc \
        | hxselect -s "-awk-" -c \
        'author > name', 'updated', 'content[type=html] table tbody tr td', \
        'content[type=html] div' | hxunent \
        | sed -E 's,-awk-([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})\+00:00,\n '$'\e[1;33m\uf073'' \4:\5:\6 \1/\2/\3 \n'$(linea ·)$'\e[0m''\n,g' \
        | sed -e 's/-awk-/ '$'\e[34m\uf118'' /1' | sed 's/-awk-/'$'\e[0m''/;' \
        | sed -E 's,([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})\+00:00,\n '$'\e[1;33m\uf073'' \4:\5:\6 \1/\2/\3 \n'$(linea ·)$'\e[0m''\n,g' \
        | sed 's/<p>//g;s/<\/p>//g;' \
        | sed 's/<pre>//g;s/<\/pre>//g;' \
        | sed 's/<em>/> /g;s/<\/em>//g;' \
        | sed 's/<ol>//g;s/<\/ol>//g;' \
        | sed 's/<br>//g;s/<\/br>//g;' \
        | sed 's/<h1>/\#/g;s/<\/h1>//g;' \
        | sed 's/<strong>/'$'\e[2;33m''/g;s/<\/strong>/'$'\e[0m''/g;' \
        | sed 's/<ul>//g;s/<\/ul>//g;' \
        | sed 's/<li>/\* /g;s/<\/li>//g;' \
        | sed 's/<blockquote>/\`\`\`/g;s/<\/blockquote>/\`\`\`/g;' \
        | sed 's/<code>/\`'$'\e[1;31m''/g;s/<\/code>/'$'\e[0m''\`/g;' \
        | sed 's/<a href="\(.*\)">\(.*\s*\)*<\/a>/[\2]\n(\1)/' \
        | sed 's/<span>//g;s/<\/span>/\n/g;' \
        | sed 's/<\/img>/Image/g;' \
        > ${_dir}/news_${_subname}_${_x}.md
    
        echo "downloading page ${_x}: ${line}" >> $_dir/errors_${_subname}
        _x=$(( $_x + 1 ))
    else
        echo "error in page ${_x}: ${line}" >> $_dir/errors_${_subname}
    fi

done

# 2.3 showing fzf
    cat ${_dir}/news_${_subname} | asc2xml | hxnormalize -x -l 150 \
    | hxselect -s "\n" -c title \
    | tail -n +2 | head -n $_howmany | cat -n \
    | fzf --reverse --preview " _preview {1} ${_subname}" \
    --preview-window=down,80% --header=$_sub
    # | sed -n ${_x}p $_dir/links_${_subname}
}

_preview() {
    local _dir="$HOME/.redditnews" _subname=${2}
    #echo "bat -p -l md ${_dir}/news_${_subname}_${1}.md"
    bat -p -l md --terminal-width ${COLUMNS} --color=always "${_dir}/news_${_subname}_${1}.md"
}

export -f _preview
