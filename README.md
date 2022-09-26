# reddit
Simple bash function for showing reddit headlines

![image](https://user-images.githubusercontent.com/93226/192123132-02697cc2-ad50-4459-a615-831c2b046051.png)

# What it does
Display headlines from any r/subreddit (default r/bash) and show comments for each one if desired.

# Usage: 
- `reddit`, show last headline from r/bash (default)
- `reddit commandline`, show 1 headline from r/commandline
- `reddit bash 10`, show 10 from r/bash
- `reddit zsh 7 show`, get 7 headlines from r/zsh, displays comments within fzf preview 

# Dependencies: 
curl

# Preview dependencies: 
gum, fzf, html-xml-utils, bat

# Notes
If your system has a *html-xml-utils* version prior to 8.0, then previews will just show author and comments, nor date.
That's because *hxselect* included with package managers is too old and doesn't allow selection of more than 2 html tags.
You might want download from https://www.w3.org/Tools/HTML-XML-utils.
