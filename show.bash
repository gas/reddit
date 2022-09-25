#!/usr/bin/bash

# Display headlines from subreddit (default r/commandline), experimental preview of comments
# Usage: reddit, reddit 4, reddit 10 bash, reddit 5 commandline show, ...
# Dependencies: curl
# Preview dependencies: gum, fzf, xmllint, html-xml-utils, recode & bat. 

reddit() 
{
local _howmany=${1:-5} _subname=${2} _sub="https://www.reddit.com/r/${2:-commandline}.rss" _dir="$HOME/.redditnews"
mkdir $_dir > /dev/null 2>&1

# get headlines
gum spin --spinner dot --title "Adquiring headlines from r/$_subname..." -- \
    curl -s -o $_dir/news_${_subname}  -A "reddit_bash_script (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15" $_sub

# just headlines, will stop after that
if [[ -z ${3} ]]; then
    xmllint --format $_dir/news_${_subname} | grep "<title>" | sed "s/<title>//g;s/<\/title>//;" \
    | sed 's/^    /· /' | tail -n +2 | head -n $_howmany
    return 1
fi

# headlines + content, did you say 'show'? ok

# links
xmllint --format $_dir/news_${_subname} | grep "<link href" \
    | sed "s/<link href=\"//g;s/\/\"\/>/.rss/;" \
    | head -n $_howmany > $_dir/links_${_subname}

# loop of contents
local _x=1
cat $_dir/links_${_subname} | while read line # || [[ -n $line ]];
do
    # curl & gum
	  gum spin --spinner dot --title "Content $_x/$_howmany from r/$_subname..." -- \
    curl -s -o $_dir/news_${_subname}_${_x}  \
    -A "reddit_bash_script (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15" $line

	  # formatting
    cat ${_dir}/news_${_subname}_${_x} | recode html..ascii 2>/dev/null \
        | hxnormalize -x \
        | hxselect -s "\n" name, "div[class=md]" \
        | sed 's/<name>/## /g;s/<\/name>//g;s/<div class=\"md\">//g;s/<\/div>/-\n***/g;' \
        | sed 's/<p>//g;s/<\/p>//g;s/<hr><\/hr>//g;/^$/d;' \
        | sed 's/<a href="\(.*\)">\(.*\s*\)*<\/a>/[\2](\1)/' \
        | sed 's/\s*<pre><code>/\n\`\`\`\n/g;s/\s*<\/code><\/pre>/\n\`\`\`/g;' \
        | sed 's/\s*<blockquote>/\`\`\`\n/g;s/\s*<\/blockquote>/\n\`\`\`/g;s/<ol>$//g;s/<\/ol>$//g;s/<ul>$//g;s/<\/ul>$//g;s/<li>/- /g;s/<\/li>//g;' \
        | sed 's/<strong>/*/g;s/<\/strong>/*/g;s/<em>//g;s/<\/em>//g;' \
        | sed 's/<br><\/br>//g;' | sed 's/\s*<pre>/\`\`\`\n/g;' \
        | sed -r 's/\s*<\/pre>\s*/\`\`\`\n/g;s/<code>/\`/g;s/<\/code>/\`/g;' \
        | hxunent \
        > ${_dir}/news_${_subname}_${_x}.md
    _x=$(( $_x + 1 ))
done

# displaying headlines and comments page with fzf
xmllint --format ${_dir}/news_${_subname} | grep "<title>" | sed "s/<title>//g;s/<\/title>//;" \
    | sed 's/^    /· /' | tail -n +2 | head -n $_howmany | cat -n \
    | fzf --reverse --preview " _preview {1} ${_subname}" \
    --preview-window=down,80% --header=$_sub
}

_preview() {
    local _dir="$HOME/.redditnews" _subname=${2}
    #echo "bat -p -l md ${_dir}/news_${_subname}_${1}.md"
    bat -p -l md --color=always "${_dir}/news_${_subname}_${1}.md"
    # echo $_index
}
export -f _preview
