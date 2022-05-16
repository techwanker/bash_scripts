    
## backup using rsync 

	DEST_DIR=$1
	TARGET_DIR=$DEST_DIR/initial/
	if ( ! -d $DEST_DIR ] ; then
		echo DEST_DIR DEST_DIR does not exist >&2
		exit 1
        fi

	if [ ! -d $TARGET_DIR ] ; then 
		mkdir $TARGET_DIR
        fi

        set -x 
        echo rsync -tav -H \
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
            --include /var/lib/pgsql \
    	    --exclude /usr/ \
            --exclude /common/oracle/oradata/ \
            --exclude /var/ \
    	    --delete  \
    	    --log-file=/tmp/rsync.log \
    	    / $TARGET_DIR 

