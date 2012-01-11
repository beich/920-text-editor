#!/bin/sh
# sh is buggy on RS/6000 AIX 3.2. Replace above line with #!/bin/ksh

# Bzcmp/diff wrapped for bzip2,中文ok——
# adapted from zdiff by Philippe Troin <phil@fifi.org> for Debian GNU/Linux.

# Bzcmp and bzdiff are used to invoke the cmp or the  diff  pro-
# gram  on compressed files.  All options specified are passed
# directly to cmp or diff.  If only 1 file is specified,  then
# the  files  compared  are file1 and an uncompressed file1.gz.
# If two files are specified, then they are  uncompressed  (if
# necessary) and fed to cmp or diff.  The exit status from cmp
# or diff is preserved.

PATH="/usr/bin:/bin:$PATH"; export PATH
prog=`echo $0 | sed 's|.*/||'`
case "$prog" in
  *cmp) comp=${CMP-cmp}   ;;
  *)    comp=${DIFF-diff} ;;
esac

OPTIONS=
FILES=
for ARG
do
    case "$ARG" in
    -*) OPTIONS="$OPTIONS $ARG";;
     *) if test -f "$ARG"; then
            FILES="$FILES $ARG"
        else
            echo "${prog}: $ARG not found or not a regular file"
            exit 1
        fi ;;
    esac
done
if test -z "$FILES"; then
        echo "Usage: $prog [${comp}_options] file [file]"
        exit 1
fi
tmp=`mktemp ${TMPDIR:-/tmp}/bzdiff.XXXXXXXXXX` || {
      echo 'cannot create a temporary file' >&2
      exit 1
}
set $FILES
if test $# -eq 1; then
        FILE=`echo "$1" | sed 's/.bz2$//'`
        bzip2 -cd "$FILE.bz2" | $comp $OPTIONS - "$FILE"
        STAT="$?"

elif test $# -eq 2; then
        case "$1" in
        *.bz2)
                case "$2" in
                *.bz2)
                        F=`echo "$2" | sed 's|.*/||;s|.bz2$||'`
                        bzip2 -cdfq "$2" > $tmp
                        bzip2 -cdfq "$1" | $comp $OPTIONS - $tmp
                        STAT="$?"
                        /bin/rm -f $tmp;;

                *)      bzip2 -cdfq "$1" | $comp $OPTIONS - "$2"
                        STAT="$?";;
                esac;;
        *)      case "$2" in
                *.bz2)
                        bzip2 -cdfq "$2" | $comp $OPTIONS "$1" -
                        STAT="$?";;
                *)      $comp $OPTIONS "$1" "$2"
                        STAT="$?";;
                esac;;
        esac
        exit "$STAT"
else
        echo "Usage: $prog [${comp}_options] file [file]"
        exit 1
fi
#end