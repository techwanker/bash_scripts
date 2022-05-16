set -x
for f in $* 
do
   md_target=`basename $f .sh`.md
   sed -e "s/#!//" $f > /tmp/$md_target
   html_target=`basename $f .sh`.html
   pandoc /tmp/$md_target -o /tmp/$html_target
   firefox /tmp/$html_target
done
