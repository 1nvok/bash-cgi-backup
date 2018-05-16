#!/bin/bash

echo 'Content-Type: text/html'
echo


if [ "$REQUEST_METHOD" = "POST" ]; then
  if [ "$CONTENT_LENGTH" -gt 0 ]; then
      read -n $CONTENT_LENGTH POST_DATA <&0
  fi
fi

fdir=todo.list/
IFS="&"
set -- $POST_DATA

function filter01(){
var01=$(echo "$1" | sed 's/dir_to_backup=//g')
}

function filter02(){
var02=$(echo "$1" | sed 's/dir_to_save=//g')
}

function filter03(){
var03=$(echo "$1" | sed '1,$ s/=.*//g')
}

function filter04(){
var04=$(echo "$1" | sed '1,$ s/=.*//g')
}


### FILTER TEXT: [ backup dir ]
function filter10()
{
local x y z
y="${1//+/ }%%"
 while [ ${#y} -gt 0 -a "${y}" != "%" ]; do
    x="${x}${y%%\%*}"
    y="${y#*%}"
       if [ ${#y} -gt 0 -a "${y}" != "%" ]; then
          z=${y:0:2}
          y="${y:2}"
          x="${x}"`echo -e \\\\x${z}`
       fi
 done
var10="${x}"
}

### FILTER TEXT: [ to save dir ]
function filter11()
{
local x y z
y="${1//+/ }%%"
 while [ ${#y} -gt 0 -a "${y}" != "%" ]; do
    x="${x}${y%%\%*}"
    y="${y#*%}"
       if [ ${#y} -gt 0 -a "${y}" != "%" ]; then
          z=${y:0:2}
          y="${y:2}"
          x="${x}"`echo -e \\\\x${z}`
       fi
 done
var11="${x}"
}


### FILTER NOT NULL:
function filter20(){
if [[ "$1" == "" ]]; then
   return 0
 else
   return 1
fi
}

function check_text_length(){
if [[ ${#1} -gt 500 ]];  then
   return 0
 else
   return 1
fi
}

function check_dir(){
if  [[ -d "$1" ]]; then
   return 1
 else
   return 0
fi
}

### IF '/path' then correct to '/path/'
function end_correction(){
case "$1" in
*/)
	echo "$1" > ./tosave.file
    ;;
*)
        echo "$1/" > ./tosave.file
    ;;
esac
}


### BUTTON REMOVE ALL:
function removeall(){
echo '<input type="submit" name="remove" value="remove all"></input>'
}

### BUTTON BACKUP:
function backup_push(){
echo '<input type="submit" name="bpush" value="Run backup"></input>'
}

### BACKUP METHOD:
function backup_start(){
#rsync -avzh `cat ./tobackup.file` `cat ./tosave.file` /dev/null 2>&1
for i in `sudo cat ./tosave.file `
   do
      local x="./tobackup.file"
      while read y
      do
         sudo tar -czvPf "$i"`date +%Y-%m-%d-%H-%M-%S-%N`.tar.gz "$y" >> ./info.file
         done < "$x"
done 2>&1
}

function catlist(){
tobackup=( `cat "./tobackup.file"` )
tosave=( `cat "./tosave.file"` )
echo '<pre>'
echo '<font size='5'><b>What we will backup:</b></font>'
echo "${tobackup[@]}"
echo '</pre>'
echo '<pre>'
echo '<font size='5'><b>Where it will be saved:</b></font>'
echo "${tosave[@]}"
echo '</pre>'
}

function backup_catlist_files(){
backup_files=( `ls "$var11"` )
echo '<pre>'
echo '<font size='5'><b>Backup done:</b></font>'
echo $var11
echo "${backup_files[@]}"
echo '</pre>'

}

function backup_catlist(){
backup_info=( `cat "./info.file"` )
echo '<pre>'
echo '<font size='5'><b>Backup done:</b></font>'
echo "${backup_info[@]}"
echo '</pre>'
}

function backup_make_history(){
cat ./tosave.file > ./tohistory.file
}

function backup_show_history(){
local x="./tohistory.file"
while read y
	do
	echo "$y" 
	ls "$y"	
done < "$x"
}

### BUTTON:
echo '<br>'
echo '<form method="POST" action="" enctype="application/x-www-form-urlencoded">'
echo '<h4> Backup Dir: </h4>'
echo '<input type="text" name="dir_to_backup" value=""></input>'
echo '<br><br>'
echo 'Where to save?:'
echo '<br>'
echo '<input type="text" name="dir_to_save"></input>'
echo '<br><br>'
echo '<input type="submit"  value="Add"></input>'
echo '<br>'
#echo $POST_DATA

### INCOMING DATA:
### FILTER FIRST HALF:
filter01 $1
filter02 $2
filter03 $3
filter04 $3

### FILTER SECOND HALF:
filter10 $var01
filter11 $var02

if [[ -a ./tobackup.file ]]; then
  if [[ "$var03" == "remove" ]]; 	then
  echo '<br>'
  echo 'All path has been removed!'
  > ./tobackup.file
  > ./tosave.file
   exit
    elif
     [[ "$var03" == "bpush" ]]; then
     echo '<br>'
     echo 'Doing...'
     #rsync -avzh `cat ./tobackup.file` `cat ./tosave.file` /dev/null 2>&1
     backup_make_history
     backup_start
       if [[ "$?" -eq 0 ]]; then
       echo 'Backup done.'; else
       echo 'Backup failed =('; 
       fi
       > ./tobackup.file
       > ./tosave.file
       echo '<br>'
       echo '<pre>'
       backup_show_history
       > ./tohistory.file
       echo '<br><br>'
       backup_catlist
       > ./info.file
       echo '</pre>'
        exit
         else
           if ( check_text_length $var10 ); then
	   echo '<br>' 
	   echo '<b>'"The backup dir name string is too large: $? "'</b>'
	     elif ( check_text_length $var11 ); then
	     echo '<br>'
	     echo '<b>'"The save dir name string is too large: "'</b>'
	      exit
	       else
	         if ( filter20 $var10 ); then
	         echo '<br><br><b>ENTER: What dir backup? & Where to save?:</b>'
	         echo '<pre>'
	         echo '### EXAMPLE:'
	         echo '/path/to/backup/'
	         echo '--------------'
	         echo '/path/to/save/'
	         echo '###'
	         echo '<pre>'
	          exit
	           else
	             if ! [[ -s ./tosave.file ]]; then
	               if ( filter20 $var11 ); then
		       echo '<br><br><b>ENTER: Where we shall to save files?:</b>'
		        exit
		         elif ( check_dir "$var10" ); then
		         echo '<br><b>Directory not exist:</b>'
		          exit
		         catlist
		         elif ( check_dir "$var11" ); then
		         echo '<br><b>Directory not exist:</b>'
		          exit
		           else
		           end_correction "$var11"
		           echo "$var10" > ./tobackup.file
		           catlist
		           fi
 	  		   else
 		             if ( check_dir "$var10" ); then
   		               echo '<br><b>Directory not exist:</b>'
		               catlist
		               echo '<br>'
	         	       backup_push
                               echo '<br><br>'
			       removeall
			        exit
			         else
				   if [[ -s ./tosave.file ]]; then
				   echo $var10 >> ./tobackup.file
				   echo '<br>'
				   catlist
				   echo "<font color='#008000'>"$var10":</font><b>New path added:</b>"
  				   echo '<br><br>'
				     else
				       echo END
				        exit 1
fi
fi
fi
fi
fi
fi
fi
echo '<br><br>'

### Button
backup_push
echo '<br><br>'
removeall
echo '</form>'
echo '<br>'
echo '<hr>'
#echo '<pre>'
#cat
#env
#echo '</pre>'









