# make-crypto-usb 

<pre>
if [ $# -ne 2 ] ; then
   echo usage: make-crypto-usb.sh device disklabel
fi


if [ -z $SECRET ] ; then 
   echo export SECRET 2>&1
   exit 1 
fi
    
set -x   
DEVICE=$1
DISKLABEL=$2

sudo cryptsetup --verbose  luksFormat $DEVICE <<:EOF:
$SECRET
:EOF:
</pre>

* verify

<pre>
sudo cryptsetup luksDump $DEVICE <<:EOF:
$SECRET
:EOF:

if [ $? -ne 0 ] ; then
	echo problem with device $DEVICE
	exit
else 
	echo found encrypted device $DEVICE
fi
</pre>

* open 
<pre>
FNAME=`basename $DEVICE`
sudo cryptsetup luksOpen $DEVICE $FNAME <<:EOF:
$SECRET
:EOF:
</pre>

* make file system
<pre>
mapper_name=`basename $DEVICE`
sudo mkfs -t ext4 /dev/mapper/${mapper_name}
</pre>

* label it
<pre>
sudo e2label /dev/mapper/${DISKLABEL}
echo diskname is $DISKNAME

if [ ! -d /disk/$DISKNAME ] ; then
	sudo mkdir /disk/$DISKNAME
fi
<pre>

# mount 
<pre>
sudo mount /dev/mapper/$FNAME /disk/$DISKNAME
</pre>



