qcd
===

Overview
--------

qcd - quick change directory

qcd allows you to create an alias for a directory

-  qcda *alias* This will create an alias for the current directory

-  qcd *alias* cd to the directory specified by the alias

-  qcdl list the aliases and associated directory

   QCD\_DATA\_FILE=\ :sub:`/.qcd.dat QCD\_HIST\_FILE=`/.qcd.hist DELIM='
   '

   qcd-check-file() { if [ ! -f $QCD\_DATA\_FILE ] ; then touch
   :math:`QCD_DATA_FILE         echo `\ QCD\_DATA\_FILE created fi if [
   ! -f $QCD\_HIST\_FILE ] ; then touch
   :math:`QCD_HIST_FILE         echo `\ QCD\_HIST\_FILE created fi }

   qcd() { if [ $# != 1 ] ; then echo usage: qcd directoryAlias return
   1; fi ALIAS=\ :math:`1     TARGET=`qcd-get-alias `\ ALIAS\` if [
   ${TARGET}"" != "" ] ; then cd
   :math:`{TARGET}         echo `\ {TARGET} >>
   :math:`{QCD_HIST_FILE}     else          echo unable to locate alias `\ {ALIAS}
   in :math:`{QCD_DATA_FILE}         echo `\ {QCD\_DATA\_FILE} \| sort
   return 1; fi }

   returns the number of times this alias is already defined
   =========================================================

   qcd-get-alias-count() { if [ $# != 1 ] ; then echo usage:
   qcd-get-alias-count directoryAlias return 1; fi local
   ALIAS\_COUNT=\ ``grep "^${ALIAS}${DELIM}" ${QCD_DATA_FILE} | cut -f2 -d"${DELIM}" | wc -l``
   #echo ALIAS\_COUNT: :math:`ALIAS_COUNT >&2     echo `\ ALIAS\_COUNT }

   qcd-get-alias() { if [ $# != 1 ] ; then echo usage: qcd-get-alias
   directoryAlias return 1; fi local
   ALIAS=\ :math:`1     local ALIAS_COUNT=`qcd-get-alias-count `\ ALIAS\ ``if [ $ALIAS_COUNT != 1 ] ; then         echo this alias has been defined $ALIAS_COUNT times, returning last entry >&2     fi     local TARGET=``\ grep
   "^:math:`{ALIAS}`\ {DELIM}"
   :math:`{QCD_DATA_FILE} | cut -f2 -d"`\ {DELIM}" \| tail -1\` if [
   ${TARGET}"" != "" ] ; then echo
   :math:`{TARGET}     else          echo unable to locate alias `\ {ALIAS}
   in ${QCD\_DATA\_FILE} >&2 return 1; fi

   }

   qcd-show-all-aliases() { if [ $# != 1 ] ; then echo usage:
   qcd-get-all-aliases directoryAlias return 1; fi local
   ALIAS=\ :math:`1     #echo numbering lines     # show the line numbers and the directory name, strip out the alias     echo directories for alias \'`\ {ALIAS}'
   grep --line-number "^:math:`{ALIAS}`\ {DELIM}" ${QCD\_DATA\_FILE} \|
   sed 's/:[^ ]\*//'

   }

   qcd-dupes() { local
   DUP\_KEYS=\ ``cat $QCD_DATA_FILE | cut -f 1 -d "$DELIM"  | sort | uniq -d``
   echo duplicate keys are $DUP\_KEYS }

   qcd-show-dupes() { local DUP\_KEYS=\ ``qcd-dupes`` for KEY in
   :math:`{DUP_KEYS}     do         local SEARCH_KEY="^`\ {KEY}:math:`{DELIM}"         #echo SEARCH_KEY is `\ SEARCH\_KEY
   grep -n ":math:`{SEARCH_KEY}" `\ {QCD\_DATA\_FILE} done }

   qcd-add-alias() { if [ $# != 2 ] ; then echo usage: qcda-add-alias
   aliasName directory return 1; fi local
   PREVIOUS\_ALIAS\_COUNT=\ ``qcd-get-alias-count ${ALIAS}`` #echo
   PREVIOUS\_ALIAS\_COUNT:
   :math:`PREVIOUS_ALIAS_COUNT     if [ `\ {PREVIOUS\_ALIAS\_COUNT} -gt
   0 ] ; then echo alias
   :math:`ALIAS has been previously defined         echo after this is added the following directory aliases will be hidden          echo edit `\ QCD\_DATA\_FILE
   if you wish to disambiguate qcd-show-all-aliases
   :math:`ALIAS     fi     if [ ! -d `\ {TARGET} ] ; then echo target
   :math:`{TARGET} is not a directory     return 2     fi     if [ ! -x `\ {TARGET}
   ] ; then echo target directory
   :math:`{TARGET} permissions do not allow you to search the directory contents     return 3     fi     ###     # resolve relative path     ###      local CURRENT_DIR=`pwd`                  # save off the current directory     cd `\ TARGET
   # change to the target directory which might be a relative path local
   CD\_RETVAL=\ :math:`?                       # check if the change directory worked     local TARGET_DIR=`pwd`                   # store of the absolute name of the target directory     if [ `\ TARGET\_DIR
   != :math:`TARGET -a `\ TARGET != '.' ] ; then # the path was relative
   and not the current directory echo TARGET\_DIR is
   :math:`TARGET_DIR for alias `\ {ALIAS} # show the resolved alias fi
   #echo CD\_RETVAL
   :math:`CD_RETVAL                     cd `\ CURRENT\_DIR # return to
   the starting point echo
   :math:`{ALIAS}"`\ {DELIM}":math:`{TARGET_DIR} >> `\ {QCD\_DATA\_FILE}
   }

   qcda() { #echo called with :math:`# args     if [ `\ # -lt 1 -o $#
   -gt 2 ] ; then echo if called with one argument it must be the alias
   you wish to create echo for the current directory. echo echo if
   called with two arguments echo the first argument must be the alias
   echo and the second argument must be a directory to which you can
   navigate return 1; fi local
   ALIAS=\ :math:`1     local TARGET     if [ `\ # = 2 ] ; then
   TARGET=\ :math:`2     else          TARGET=`pwd`      fi     qcd-add-alias `\ ALIAS
   $TARGET }

   qcdl() { echo your data file
   :math:`QCD_DATA_FILE has the following entries     cat `\ QCD\_DATA\_FILE
   }

   qcds() { # Quick Change Directory Save cd :math:`1 && (echo `\ {PWD}
   >> ${QCD\_HIST\_FILE}) }

   qcdh() { # need a session level list and a global list awk '!($0 in
   x){x[$0]++; print :math:`0}' `\ {QCD\_HIST\_FILE} }

   qcd-check-file

   alias pcd="pushd .; qcd"


