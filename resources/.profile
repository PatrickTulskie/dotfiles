# Make terminal delete key compatible with remote servers
stty erase ^H

##
# DELUXE-USR-LOCAL-BIN-INSERT
# (do not remove this comment)
##
echo $PATH | grep -q -s "/usr/local/bin"
if [ $? -eq 1 ] ; then
    # PATH=$PATH:/usr/local/bin
    PATH=/usr/local/bin:$PATH
    export PATH
fi

echo $PATH | grep -q -s "/usr/local/sbin"
if [ $? -eq 1 ] ; then
    # PATH=$PATH:/usr/local/sbin
    PATH=/usr/local/sbin:$PATH
    export PATH
fi