#!/usr/bin/env bash
# cookbook filename: cdscript
# cdscript - prep and burn a CD from a dir.
# 需要有mkisofs 和 cdrecord两个命令的支持
# usage: cdscript dir [ cddev ]
#
if [[ $# < 1 || $# > 2 ]]
then
    echo 'usage: cdscript dir [ cddev ]'
    exit 2
fi

# set the defaults
SRCDIR=$1
# your device might be "ATAPI:0,0,0" or other digits
CDDEV=${2:-"ATAPI:0,0,0"}
ISOIMAGE=/tmp/cd$$.iso

echo "building ISO image..."
#
# make the ISO fs image
#
mkisofs $ISOPTS -A "$(cat ~/.cdAnnotation)" \
    -p "$(hostname)" -V "$(basename $SRCDIR)" \
    -r -o "$ISOIMAGE" $SRCDIR
STATUS=$?
if [ $STATUS -ne 0 ]
then
    echo "Error. ISO image failed."
    echo "Investigate then remove $ISOIMAGE"
    exit $STATUS
fi

echo "ISO image built; burning to cd..."
exit

# burn the CD
SPD=8
OPTS="-eject -v fs=64M driveropts=burnproof"
cdrecord $OPTS -speed=$SPD dev=${CDDEV} $ISOImage
STATUS=$?
if [ $STATUS -ne 0 ]
then
    echo "Error. CD Burn failed."
    echo "Investigate then remove $ISOIMAGE"
    exit $STATUS
fi

rm -f $ISOIMAGE
echo "Done."
