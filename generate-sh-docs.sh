# generate-sh-docs.sh

#!* https://riptutorial.com/sed/example/8893/backreference

#!* Check arguments

#!<pre>
if [ $# -ne 1 ] ; then
    echo usage generate-sh-docs.sh DIRNAME >&2
    echo using `pwd`
    dirname=`pwd`
else 
    dirname=$1
fi

cd $dirname
if [ ! -d generated_docs ]; then
    mkdir generated_docs
fi

set -x 
for file in *.sh
do
   set -o noglob
   #!* create a markdown file
   filename=`basename $file .sh`
   mdtarget=generated_docs/${filename}.md
   #sed -e "s/#!//" ${file} > $mdtarget
   sed -E 's/^ *#!(.*)/\1/' ${file} > $mdtarget
   #!* create a rst file for sphynx
   rsttarget=generated_docs/${filename}.rst 
   pandoc $mdtarget -o  generated_docs/${filename}.rst
done

cd generated_docs
if [ -f index.rst ] ; then
    make html
    make singlehtml
    firefox _build/singlehtml/index.html
fi
#!</pre>
