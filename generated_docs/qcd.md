# qcd

## Overview

qcd - quick change directory

qcd allows you to create an alias for a directory

 * qcda *alias*
 This will create an alias for the current directory

 * qcd *alias*
 cd to the directory specified by the alias 

 * qcdl 
    list the aliases and associated directory
    
    QCD_DATA_FILE=~/.qcd.dat
    QCD_HIST_FILE=~/.qcd.hist
    DELIM=' '  
    
    qcd-check-file() {
        if [ ! -f $QCD_DATA_FILE ] ; then
            touch $QCD_DATA_FILE
            echo $QCD_DATA_FILE created
        fi 
        if [ ! -f $QCD_HIST_FILE ] ; then
            touch $QCD_HIST_FILE
            echo $QCD_HIST_FILE created
        fi
    }
    
    qcd() {
        if [ $# != 1 ] ; then
            echo usage: qcd directoryAlias
            return 1;
        fi
        ALIAS=$1
        TARGET=`qcd-get-alias $ALIAS`
        if [ ${TARGET}"" != "" ] ; then
            cd ${TARGET}
            echo ${TARGET} >> ${QCD_HIST_FILE}
        else 
            echo unable to locate alias ${ALIAS} in ${QCD_DATA_FILE}
            echo ${QCD_DATA_FILE} | sort
            return 1;
        fi
    }
    
    #
    # returns the number of times this alias is already defined
    #
    qcd-get-alias-count() {
        if [ $# != 1 ] ; then
            echo usage: qcd-get-alias-count directoryAlias
            return 1;
        fi
        local ALIAS_COUNT=`grep "^${ALIAS}${DELIM}" ${QCD_DATA_FILE} | cut -f2 -d"${DELIM}" | wc -l`
        #echo ALIAS_COUNT: $ALIAS_COUNT >&2
        echo $ALIAS_COUNT
    }
    
    
    qcd-get-alias() {
        if [ $# != 1 ] ; then
            echo usage: qcd-get-alias directoryAlias
            return 1;
        fi
        local ALIAS=$1
        local ALIAS_COUNT=`qcd-get-alias-count $ALIAS`
        if [ $ALIAS_COUNT != 1 ] ; then
            echo this alias has been defined $ALIAS_COUNT times, returning last entry >&2
        fi
        local TARGET=`grep "^${ALIAS}${DELIM}" ${QCD_DATA_FILE} | cut -f2 -d"${DELIM}" | tail -1`
        if [ ${TARGET}"" != "" ] ; then
            echo ${TARGET}
        else 
            echo unable to locate alias ${ALIAS} in ${QCD_DATA_FILE} >&2
        return 1;
        fi
        
    }
    
    qcd-show-all-aliases() {
        if [ $# != 1 ] ; then
            echo usage: qcd-get-all-aliases directoryAlias
            return 1;
        fi
        local ALIAS=$1
        #echo numbering lines
        # show the line numbers and the directory name, strip out the alias
        echo directories for alias \'${ALIAS}\'
        grep --line-number "^${ALIAS}${DELIM}"  ${QCD_DATA_FILE} | sed 's/:[^ ]*//'
    
    }
    
    qcd-dupes() {
        local DUP_KEYS=`cat $QCD_DATA_FILE | cut -f 1 -d "$DELIM"  | sort | uniq -d`
        echo duplicate keys are $DUP_KEYS
    }
    
    qcd-show-dupes() {
        local DUP_KEYS=`qcd-dupes`
        for KEY in ${DUP_KEYS}
        do
            local SEARCH_KEY="^${KEY}${DELIM}"
            #echo SEARCH_KEY is $SEARCH_KEY
            grep -n "${SEARCH_KEY}" ${QCD_DATA_FILE}
        done
    }
    
    qcd-add-alias() {
        if [ $# != 2 ] ; then
            echo usage: qcda-add-alias aliasName directory
            return 1;
        fi
        local PREVIOUS_ALIAS_COUNT=`qcd-get-alias-count ${ALIAS}`
        #echo PREVIOUS_ALIAS_COUNT: $PREVIOUS_ALIAS_COUNT
        if [ ${PREVIOUS_ALIAS_COUNT} -gt 0 ] ; then
            echo alias $ALIAS has been previously defined
            echo after this is added the following directory aliases will be hidden 
            echo edit $QCD_DATA_FILE if you wish to disambiguate
            qcd-show-all-aliases $ALIAS
        fi
        if [ ! -d ${TARGET} ] ; then
            echo target ${TARGET} is not a directory
        return 2
        fi
        if [ ! -x ${TARGET} ] ; then
            echo target directory ${TARGET} permissions do not allow you to search the directory contents
        return 3
        fi
        ###
        # resolve relative path
        ### 
        local CURRENT_DIR=`pwd`                  # save off the current directory
        cd $TARGET                               # change to the target directory which might be a relative path
        local CD_RETVAL=$?                       # check if the change directory worked
        local TARGET_DIR=`pwd`                   # store of the absolute name of the target directory
        if [ $TARGET_DIR != $TARGET -a $TARGET != '.' ] ; then     # the path was relative and not the current directory
            echo TARGET_DIR is $TARGET_DIR for alias ${ALIAS}          # show the resolved alias
        fi
        #echo CD_RETVAL $CD_RETVAL                
        cd $CURRENT_DIR                          # return to the starting point
        echo ${ALIAS}"${DELIM}"${TARGET_DIR} >> ${QCD_DATA_FILE} 
    }
    
    qcda() {
        #echo called with $# args
        if [ $# -lt 1  -o $# -gt 2 ] ; then
            echo if called with one argument it must be the alias you wish to create
            echo for the current directory.
            echo 
            echo if called with two arguments
            echo the first argument must be the alias
            echo and the second argument must be a directory to which you can navigate
            return 1;
        fi
        local ALIAS=$1
        local TARGET
        if [ $# = 2 ] ; then
            TARGET=$2
        else 
            TARGET=`pwd` 
        fi
        qcd-add-alias $ALIAS $TARGET
    }
    
    qcdl() {
        echo your data file $QCD_DATA_FILE has the following entries
        cat $QCD_DATA_FILE 
    }
    
    qcds()  {   # Quick Change Directory Save
    	cd $1 && (echo ${PWD}  >> ${QCD_HIST_FILE})
    }
    
    qcdh()  {
        # need a session level list  and a global list
        awk '!($0 in x){x[$0]++; print $0}' ${QCD_HIST_FILE}
    }
    
    qcd-check-file
    
    alias pcd="pushd .; qcd"
