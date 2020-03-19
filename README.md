# brb
brb - be right bash - yet another bash directory bookmark script

## Usage

```
# Search and select bookmark (interactive fuzzy search)
brb
# Add the current working directory as bookmark
brb -a
# Remove the current working directory from your bookmarks
brb -r
# List all bookmarks
brb -l
```

## Installation

### fzf

```brb``` requires ```fzf``` to work properly. 
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```
Check out the [documentation of fzf](https://github.com/junegunn/fzf) for more information.

### .bashrc

Since the ```cd``` operation cannot be implemented in standalone script we need to define a shell function inside ```.bashrc```.

```
# Setup brb function
# ------------------
unalias brb 2> /dev/null
brb() {
   if [ $# -eq 0 ] ; then
      local bookmark_location="$(brb.sh)"
      if [[ "${bookmark_location}" != '' ]]; then
         cd "${bookmark_location}"
      fi
   else
      brb.sh $@
   fi
}
export -f brb > /dev/null
```

In addition you need to add ``´brb``` to your PATH. This can be done by adding following line to the end of ```.bashrc```.

```
export PATH="/path/to/brb/:${PATH}"
```