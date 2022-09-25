# reddit
Simple bash function for showing reddit headlines

![image](https://user-images.githubusercontent.com/93226/192123132-02697cc2-ad50-4459-a615-831c2b046051.png)

# What it does
Display headlines from any r/subreddit (default r/commandline), experimental preview of comments

# Usage: 
- `reddit`, show 5 headlines from r/commandline
- `reddit 4`, idem but 4
- `reddit 10 bash`, show 10 from r/bash
- `reddit 5 commandline show`, get 5 headlines, display within fzf and preview of content

# Dependencies: 
curl

# Preview dependencies: 
gum, fzf, xmllint, html-xml-utils, recode & bat. 
