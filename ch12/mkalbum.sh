#!/usr/bin/env bash
# cookbook filename: mkalbum
# mkalbum - make an html "album" of a pile of photo files.
# ver. 0.2
#
# An album is a directory of html pages.
# It will be created in the current directory.
#
# An album page is the html to display one photo, with
# a title that is the filename of the photo, along with
# hyperlinks to the first, previous, next, and last photos.
#
# ERROUT
ERROUT()
{
    printf "%b" "$@"
} >&2
#
# USAGE
USAGE()
{
    #basename命令
    ERROUT "usage: %s <newdir>\n" $(basename $0)
}

# EMIT(thisph, startph, prevph, nextph, lastph)
EMIT()
{
  THISPH="../$1"
  # 去掉文件后缀名的好方法（比批量replace好多了）
  STRTPH="${2%.*}.html"
  PREVPH="${3%.*}.html"
  NEXTPH="${4%.*}.html"
  LASTPH="${5%.*}.html"
  if [ -z "$3" ]
  then
      PREVLINE='<TD> Prev </TD>'
  else
      PREVLINE='<TD> <A HREF="'$PREVPH'"> Prev </A> </TD>'
  fi
  if [ -z "$4" ]
  then
      NEXTLINE='<TD> Next </TD>'
  else
      NEXTLINE='<TD> <A HREF="'$NEXTPH'"> Next </A> </TD>'
  fi
# 这种Here-document会解析变量
cat <<EOF
<HTML>
<HEAD><TITLE>$THISPH</TITLE></HEAD>
<BODY>
  <H2>$THISPH</H2>
<TABLE WIDTH="25%">
  <TR>
  <TD> <A HREF="$STRTPH"> First </A> </TD>
  $PREVLINE
  $NEXTLINE
  <TD> <A HREF="$LASTPH"> Last </A> </TD>
  </TR>
</TABLE>
  <IMG SRC="$THISPH" alt="$THISPH"
   BORDER="1" VSPACE="4" HSPACE="4"
   WIDTH="800" HEIGHT="600"/>
</BODY>
</HTML>
EOF
}
   
if (( $# != 1 ))
then
    USAGE
    exit -1
fi
ALBUM="$1"
if [ -d "${ALBUM}" ]
then
    ERROUT "Directory [%s] already exists.\n" ${ALBUM}
    USAGE
    exit -2
else
    mkdir "$ALBUM"
fi
cd "$ALBUM"

PREV=""
FIRST=""
#最后一个文件命名为last是因为，创建完文件以后会创建一个
LAST="last"

while read PHOTO
do
    # prime the pump
    # 第一次执行then中的内容,
    if [ -z "${CURRENT}" ]
    then
        CURRENT="$PHOTO"
        FIRST="$PHOTO"
        continue        
        # 第一次时，不执行下面到done的代码
    fi


    PHILE=$(basename "${CURRENT}")
    # EMIT(thisph, startph, prevph, nextph, lastph)
    EMIT "$CURRENT" "$FIRST" "$PREV" "$PHOTO" "$LAST" > "${PHILE%.*}.html"
    
    # set up for next iteration
    PREV="$CURRENT"
    CURRENT="$PHOTO"
   
done
   
PHILE=$(basename ${CURRENT})
EMIT "$CURRENT" "$FIRST" "$PREV"   ""   "$LAST" > "${PHILE%.*}.html"
  
# make the symlink for "last"
ln -s "${PHILE%.*}.html" ./last.html

# make a link for index.html
ln -s "${FIRST%.*}.html" ./index.html

