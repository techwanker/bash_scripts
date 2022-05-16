    #set -x
    set -e
    LOG_DIR=/scratch/logs
    LOG_PREFIX=MagicTimeMachine_
    #usbdrive the device backed up to 
    #
    echo_stderr()
    {
        echo "$@" >&2
    }
    
    check_args() {
    	if [ $# -eq 0 ] ; then
            echo_stderr using default_dest `default_dest`
    	    BACKUP_DIR=`default_dest`
    	    return 0
    	fi
    	if [ $# -ne 1 ] ; then
    	    echo_stderr usage $0 destination_dir
    	    exit 1
    	fi
    	BACKUP_DIR=$1
    	if [ ! -d $BACkUP_DIR  ] ; then
    	    echo_stderr $BACKUP_DIR is not a directory
    	    exit 1
    	fi
    	if [ ${BACKUP_DIR}x == x ] ; then
        		echo_stderr Specify backup directory e.g. /disk/backup/backups/asus
        		echo_stderr the final directory name must be the name of this host
        		exit 1
    	fi
    }
    
    get_one_usb_drive() {
    	usbdrive=`mount |  cut  -f 3 -d" " | grep /run/media`
    	usbdrive_count=`mount |  cut  -f 3 -d" " | grep /run/media | wc -l`  
    	if [ $usbdrive_count -ne 1 ] ; then
    		echo_stderr expected 1 usb drive found $usbdrive_count
    	        echo_stderr $usbdrive
    		echo_stderr exiting.....
    		exit 1
    		echo_stderr this should not show
    	fi
    	echo_stderr usbdrive is $usbdrive
    	if [ ! -d $usbdrive ] ;  then
    		echo_stderr expected one usb drive found $usbdrive
    		exit 1
    	fi
    	echo_stderr default drive is $usbdrive
    	echo $usbdrive	
    }
    
    default_dest() {
    	set -e   # the exit 
    	usbdrive=`get_one_usb_drive`
    	echo_stderr retval fro get_one_usb_drive $?
    	echo_stderr default_dest usbdrive $usbdrive
    	hostnm=`hostname`
    	dest=$usbdrive/backups/$hostnm
    	if [ ! -d $dest ] ; then
    		echo_stderr destination does not exist $dest
    		exit 1
    	fi	
    	echo_stderr using default destination $dest
    	echo $dest
    }
    
    set_vars() {
    	HOSTNAME=`hostname`
    	echo_stderr HOSTNAME $HOSTNAME
    
    	TIMESTAMP=`date "+%Y-%m-%d_%H-%M-%S"`
    	echo_stderr TIMESTAMP ${TIMESTAMP}
    
    	DEST_ROOT=${BACKUP_DIR}/${TIMESTAMP}
    	echo_stderr DEST_ROOT $DEST_ROOT
    
    	NEWEST=`ls -d1tr $BACKUP_DIR/* | tail -1`
    	echo_stderr NEWEST ${NEWEST}
    
    	if [ ! -d $BACKUP_DIR ] ; then
        		echo_stderr BACKUP_DIR $BACKUP_DIR does not exist. Terminating with error	
    		exit 1
    	fi
    
    	BACKUP_DIR_HOST=`basename $BACKUP_DIR`
    	echo_stderr BACKUP_DIR_HOST $BACKUP_DIR_HOST 
    	echo_stderr HOSTNAME $HOSTNAME
    	if [ ${BACKUP_DIR_HOST} != ${HOSTNAME} ] ; then
       		echo_stderr BACKUP_DIR $BACKUP_DIR directory is not $HOSTNAME must be your hostname
    		exit 1
    	fi
    	mkdir -p $LOG_DIR
    
    	log_file=$LOG_DIR/${LOG_PREFIX}${TIMESTAMP}_backup.log
    	log_verify_file=$LOG_DIR/${LOG_PREFIX}${TIMESTAMP}_verify.log
    }
    
    show_vars() {
    	echo_stderr HOSTNAME $HOSTNAME
    	echo_stderr TIMESTAMP ${TIMESTAMP}
    	echo_stderr DEST_ROOT $DEST_ROOT
    	echo_stderr NEWEST ${NEWEST}
    }

# hard link
 clone with hard links
 
  This clones a backup directory with hard links and then syncs with 
  the source dir replacing files that have changed and deleting those ommitted.
 
 This allows recovery to any backup point with minimal space consumption in the backup
 Typical incremental backups don't delete the deleted files
    
    
    # TODO should check if writable
    # TODO should have repository by host
    # TODO check if DEST ends in "/"
    
    hard_link() {
    	if [ $#  != 2 ] ; then
             echo_stderr requires 2 args found $# $*
    	     exit 1
    	fi
    	SRC_DIR=$1
        DEST_DIR=$2
    
    	if [ ! -d $SRC_DIR ] ; then
    	     echo_stderr $SRC_DIR does not exist
    	     exit 1
    	fi;
    
    	DEST_PARENT=`dirname $DEST_DIR`
    	if [ ! -d $DEST_PARENT ] ; then
    		echo_stderr parent DEST_PARENT $DEST_PARENT does not exist or is not a directory
    		exit 1
    	fi;
    	set -x
    	cp -al  $SRC_DIR $DEST_DIR
    }
    
    
## backup using rsync 

    backup() {
        set -x 
        rsync -ta -H \
            --progress \
    	    --exclude /boot/ \
    	    --exclude /common/backups \
    	    --exclude /common/oracle/diag/rdbms/dev12c/dev12c/trace/ \
            --exclude /common/oracle/diag/rdbms/dev18b/dev18b/trace/ \
    	    --exclude /common/scratch  \
    	    --exclude /dev/  \
    	    --exclude /run/  \
            --exclude /disk/ \
    	    --exclude /proc/  \
    	    --exclude /tmp/  \
    	    --exclude /sys/  \
    	    --exclude /scratch/  \
    	    --include /usr/local/ \
    	    --exclude /usr/ \
            --exclude /common/oracle/oradata/ \
            --exclude /var/ \
    	    --delete  \
    	    --log-file=/tmp/rsync.log \
    	    / $DEST_DIR > $DEST_DIR/rsync.log &
        tail -f $DEST_DIR/rsync.log &
    }

## verify     
    verify() {
    	rsync -tav -H --dry-run \
    		--exclude /run/media \
    		--exclude /proc \
    		--exclude /run \
    		--exclude /disk \
    		--delete   \
    		/ $DEST_DIR   \
    		 2>&1  | tee $log_verify_file
    
    }
    
    log_backup_device() {
        device_log=$LOG_DIR/${log_prefix}devices.log
        echo device_log $device_log
        touch $device_log
        sed -i -e "/$usbdrive/d" $device_log
        echo $usbdrive $TIMESTAMP >> $device_log
    }
   
## update the mlocate file on the external drive  
    update_disk_db() {
       cd ${usb_drive} && sudo updatedb --database-root . -o ./disk.db
    }
    
    
    check_args $*
    set_vars
    show_vars
    echo "begin hard link"
    hard_link $NEWEST $DEST_ROOT
    backup
    verify
    log_backup_device
    update_disk_db
