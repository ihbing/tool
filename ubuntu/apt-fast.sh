# !/bin/sh
# apt-fast v0.03 by Matt Parnell http://www.mattparnell.com, this thing is fully open-source
# if you do anything cool with it, let me know so I can publish or host it for you
# contact me at admin@mattparnell.com

# Special thanks
# Travis/travisn000 - support for complex apt-get commands
# Allan Hoffmeister - aria2c support
# Abhishek Sharma - aria2c with proxy support
# Richard Klien - Autocompletion, Download Size Checking (made for on ubuntu, untested on other distros)
# Patrick Kramer Ruiz - suggestions - see Suggestions.txt
# Sergio Silva - test to see if axel is installed, root detection/sudo autorun

# Use this just like apt-get for faster package downloading.

# Check for proper priveliges
[ "`whoami`" = root ] || exec sudo "$0" "$@"

# Test if the axel is installed
if [ ! -x /usr/bin/axel ]
then echo "axel is not installed, perform this?(y/n)"
    read ops
    case $ops in
         y) if apt-get install axel -y --force-yes
               then echo "axel installed"
            else echo "unable to install the axel. you are using sudo?" ; exit
            fi ;;
         n) echo "not possible usage apt-fast" ; exit ;;
    esac
fi

# If the user entered arguments contain upgrade, install, or dist-upgrade
if echo "$@" | grep -q "upgrade\|install\|dist-upgrade"; then
  echo "Working...";

  # Go into the directory apt-get normally puts downloaded packages
  cd /var/cache/apt/archives/;

  # Have apt-get print the information, including the URI's to the packages
  # Strip out the URI's, and download the packages with Axel for speediness
  # I found this regex elsewhere, showing how to manually strip package URI's you may need...thanks to whoever wrote it
  apt-get -y --print-uris $@ | egrep -o -e "(ht|f)tp://[^\']+" > apt-fast.list && cat apt-fast.list | xargs -l1 axel -a

  # Perform the user's requested action via apt-get
  apt-get $@;

  echo -e "\nDone! Verify that all packages were installed successfully. If errors are found, run apt-get clean as root and try again using apt-get directly.\n";

else
   apt-get $@;
fi