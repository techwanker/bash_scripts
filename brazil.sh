# brazil

## Usage
#! . brazil.sh to load the function

#! This maintains the ~/.ssh/config file and 
#! * a comment with the format *#:alias:hostname:identityfile*
#! * It also creates a host IdentityFile entry
#! example:

#!<pre>
#!ServerAliveInterval 120
#:javautil-7:ec2-3-87-156-115.compute-1.amazonaws.com:javautil-6.pem
#!Host ec2-3-87-156-115.compute-1.amazonaws.com
#!IdentityFile ~/.ssh/javautil-6.pem
#!</pre>

## brazil ssh *alias*
## brazil list 
#! show the aliases and hostnames 

## brazil add

#! * Adds or replaces the entry in ~/.amazon
#! * adds an entry to ~/.ssh/config 
#! ### example
#!    brazil add aliasName hostname pemfile
#! 
 
## brazil ssh *alias*

#!* ssh ec2-user@hostname

## brazil sethost *alias*
#! export host=**hostname**

#!~~~
brazil() {
    alias_file=~/.ssh/config

    cmd=$1
    export alias=$2
    echo cmd is $cmd alias is $alias
    the_hostnm=`awk -F: '{if ($2 == "'$alias'")  {print $3; exit}}' $alias_file`
    if [ $cmd == 'add' ] ; then  
        if [ $# -ne 4 ] ; then 
            echo usage add alias hostname pemfile 2>&1
            return 0
        fi
        alias=$2
        host_nm=$3
        pem=$4
#!~~~
#!* ensure the identify file exists and set permissions
#!~~~
        identity_file=~/.ssh/${pem}
        if [ ! -f $identity_file ] ; then
            echo $identity_file does not exist 2>&1
            return 1
        else 
            chmod 600 $identity_file
        fi
#!~~~
#!* is the alias in the file?
#!~~~
    grep "#:${alias}:"  ${alias_file} # TODO need a bettter pattern
    if [ $? -eq 1 ] ; then # not present add 
        echo adding $alias $hostname $pem
        echo "#:${alias}:${host_nm}:${pem}"  >> $alias_file 
        echo Host ${host_nm} >> ~/.ssh/config
            echo "    IdentityFile ./.ssh/$identity_file"
            echo pem is $pem
            echo "    IdentityFile ~/.ssh/${pem}" >> ~/.ssh/config 
        else 
            set -x
	    cat ~/.ssh/config
            echo changing hostname for  $alias $hostname $pem
            sed -i -e "s/:.*/:${host_nm}/" ${alias_file}
            sed -i -e "s/:.*/:${host_nm}/" ~/.ssh/config
        fi    
        chmod 600 ~/.ssh/config 
        echo new ~/.ssh/config
        cat ~/.ssh/config
    else 
        if [ -z $the_hostnm ] ; then
             set +x 
             echo alias $alias not found in: >&2
             cat ~/.ssh/config >&2
        else 
            echo the_hostnm is $the_hostnm
            case $cmd in 
               "ssh")
                    if [ $# -ne 2 ] ; then
                       echo "usage brazil ssh alias" 2>&1
                       return 1
                    fi
                    echo connecting to $alias ${the_hostnm}
                    ssh ec2-user@${the_hostnm} ;;
               "list") 
                    cat ~/.ssh/config ;;
               "edit")
                    vim ~/.ssh/config 
                    . ~/bin/brazil.sh ;;
               "scp") 
                   set -x
                   last_arg=${@:$#}
                   arg_count=$# 
                   echo arg_count ${arg_count}
                   leading_arg_count=`expr ${arg_count} - 2`
                   echo leading_arg_count ${leading_arg_count}
                   leading_args=${@:1:${leading_arg_count}}
                   echo leading_args ${leading_args}
                   echo last_arg $last_arg
                   echo scp $leading_args ec2-user@${the_hostnm}:${last_arg} ;;
               "sethost")
                   export host=${the_hostnm}
                   export user=ec2-user
                   export amazon="${the_hostnm}"
                   echo host set to ${the_hostnm} ;;
               *) 
                   echo usage "brazil command args"
                   echo "command is sethost edit list ssh add" ;;
          esac
       fi
   fi
}
#!~~~

# define aliases    
#!~~~
alias braziladd="brazil add" 
alias brazilssh="brazil ssh"
alias brazilhost="brasil sethost"
alias brazillist="brazil list"
#!~~~
