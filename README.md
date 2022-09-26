# reddit
Simple bash function for showing reddit headlines

![image](https://user-images.githubusercontent.com/93226/192354294-24e65a75-6bb1-4bc9-a824-0f3e9b48d28f.png)

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
You might want to download and install a newer one from https://www.w3.org/Tools/HTML-XML-utils.

```
$ reddit | cowsay
 _______________________
< set -x is your friend >
 -----------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
