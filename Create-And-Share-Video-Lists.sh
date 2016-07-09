#!/bin/bash
#title           :Create-And-Share-Video-Lists.sh
#description     :This script will create and share video playlists (pls, m3u).
#author		 :Michał Kacprzak (e-kacprzak.eu)
#date            :20160708
#version         :0.6
#usage		 :./Create-And-Share-Video-Lists.sh
#notes           :Install rsync, avconv and  to use this script.
#bash_version    :4.3.42(1)-release
#=============================================================================

clear
echo -e 'Create-And-Share-Video-Lists.sh by Michał Kacprzak (e-kacprzak.eu)\n'

# Checking if depencies is installed
checkDep(){
command -v $1 >/dev/null 2>&1 || { echo -e >&2 "***I require $1 but it's not installed. Aborting."; exit 1; }
}

checkDep avconv
checkDep rsync

############# MAIN VARIABLES #############
MainFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VideoFolder=`cat $MainFolder/VideoFolder`
RemoteServer=`cat $MainFolder/http_prelink`
LogFolder=/var/log/Create-And-Share-Video-Lists/
LogFilePath=$LogFolder"/log"

#Checking all necessary configs

if [ -s $VideoFolder ]; then
  echo "/n"
  echo '***Not defined local video folder!'
  echo "***Add a full local path in $MainFolder/VideoFolder (eg. \"/home/user/Videos\") where I can find Videos"
  echo '***Do not forget to share that folder through http server and give access for script user!!!'
  echo 'Exiting...'
  exit
fi

if [ -s $RemoteServer ]; then
  echo '***Not defined http prelink for http address!'
  echo "***Add a http address path eg. \"https://user:password/example.com/access/from/http/server/\") which I will use to create playlist links in $MailFolder/http_prelink"
  echo 'Exiting...'
  exit
fi

if [ -s $MainFolder"/clients/pls" ] && [ -s  $MainFolder"/clients/m3u"]; then
  echo "$MainFolder/clients/pls and $MainFolder/clients/m3u are empty."
  echo "***Script will generate playlists file but it won't synchronize with other devices!"
  echo "***Waiting 5 secs..."
  sleep 5
fi


############# FUNCTIONS #############
####### Operations on logs file #######
log(){
LogDate=$(date +'%y%m%d')

if [ ! -d "$LogFolder" ]; then
  mkdir -p $LogFolder;
fi

log_file=$LogFilePath"."$LogDate

if [ "$2" = "NT" ]; then
  echo -e $1 >> $log_file
else
  echo -e "$(date +'%T')_"$1 >> $log_file
fi
}

####### List All Files #######
LAF() {
ls -R $1 | awk '
/:$/&&f{s=$0;f=0}
/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
NF&&f{ print s"/"$0 }'
}

####### Check clients with path in file #######
####### $1 -----> File with listed clients and full path  
####### $2 -----> Local foder with playlist files
SynchLists () {
  while IFS='' read Remote || [[ -n $Remote ]]; do

    client=`echo ${Remote%:*}`
    clientIP=`echo ${client##*@}`

    log "Checking ip "$clientIP"..."

    if ping -q -c 1 $clientIP;  then
      log "Client $client found!"
      log "--> START SYNCHRONIZING FOR $clientIP ($Remote)"

       rsync -a --delete $2 $Remote
      if [ "$?" -eq "0" ]; then
        log "SYNCHRONIZING FOR $clientIP..."
      else
        log "Error while running rsync"
      fi

    log "--> STOP SYNCHRONIZING FOR $clientIP"

    else
      log "$clientIP NOT FOUND"
    fi
 done < "$1"
}

###############################################################################################

############# PROGRAM #############

while [ 1 -eq 1 ]; do

  SECONDS=0

  Date=$(date +'%y%m%d')
  Time=$(date +'%T')

  log "------>START"

  log "Remote address: $RemoteServer"

  ListFolder=$LogFolder"scanned_files"/
  ActualListFolder=$ListFolder$Date/
  LastListFile=$ListFolder"last_scan"
  ActualListFile=$ActualListFolder"list."$Time
  ListsFolder=$LogFolder"actual_play_list"/
  PlsFolder=$ListsFolder"pls"/
  M3uFolder=$ListsFolder"m3u"/
  log "List folder: $ActualListFolder, Actual list file: $ActualListFile"

  if [ ! -d "$ActualListFolder" ]; then
    mkdir -p $ActualListFolder
    log "Creating list folder: $ActualListFolder"
  fi

  log "Local video folder: $VideoFolder"

  LAF $VideoFolder > $ActualListFile
  log "Generated movie list: $ActualListFile"

  OldDate=$(date -d "now -14 days" +'%y%m%d')
  OldLogs=$LogFilePath"."$OldDate

  if [ -f "$OldLogs" ]; then
    rm $OldLogs;
    log "Removed Old Logs File: $OldLogs"
  fi

  OldListFolder=$ListFolder""$OldDate
  if [ -d "$OldListFolder" ]; then
    rm -r $OldListFolder
    log "Removed Old List Folder: $OldListFolder"
  fi

##### Checking if there any new file #####

  grep -qFxvf $ActualListFile $LastListFile
  if [ "$?" != 1 ]; then
    log "------>Found new files!"

##### Removing old files #####

    if [ -d "$ListsFolder" ]; then
      rm -r $ListsFolder;
      log "Removed old playlists folder"
    fi

###### START MAIN FUNCTION ######

  log "----> START CONVERTING"
  while IFS='' read -r line || [[ -n "$line" ]]; do
    name=`echo $line | sed 's#.*/##'`
    title=`echo ${name%.*}`
    extension="${name##*.}"
    globalpath=`echo $line | sed "s#$title*##"`
    plspath=`echo $line | sed "s#$VideoFolder#$PlsFolder#" | sed "#$name##"`
    m3upath=`echo $line | sed "s#$VideoFolder#$M3uFolder#"`
    remotepath=`echo $line | sed "s#$VideoFolder#$RemoteServer#"`
    pathtomovie=`echo $remotepath | sed "s/\s\+/%20/g"`

    if [ ! -d "$plspath" ]; then
      mkdir -p "$plspath"
      rm -r "$plspath"
    fi
    if [ ! -d "$m3upath" ]; then
      mkdir -p "$m3upath"
      rm -r "$m3upath"
    fi

  if [ \( "$extension" == "avi" \) -o \( "$extension" == "mkv" \) -o \( "$extension" == "mp4" \) ]; then

    if [ "$extension" = "mkv" ]; then
      durword="DURATION"
    else
      durword="Duration"
    fi

    movieduration=$(avconv -i $line 2>&1 | grep "$durword" | cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }')
    
    plsfile=$plspath".pls"

    log "---------> Processing FOR $name"
    log "--PLS--> Localization: $plsfile\n--pls--> File1=$pathtomovie\n--pls--> Title1=$title\n--pls--> Lenght1=$movieduration" NT

  echo "[playlist]
NumberOfEntries=1

File1=$pathtomovie
Title1=$title
Length1=$movieduration" > "$plsfile"

    m3ufile=$m3upath".m3u"

    log "--M3U--> Localization: $m3ufile\n--m3u--> #EXTINF:$movieduration,$title\n--m3u--> $pathtomovie" NT

  echo "#EXTM3U 
#EXTINF:$movieduration,$title
$pathtomovie" > "$m3ufile"

    fi

  done < "$ActualListFile"
  log "----> STOP CONVERTING"

  log "----> Update lasst_scan"
  cp $ActualListFile $LastListFile

  log "----> START SYNCHONIZING PLAYLIST FILES"

  SynchLists $MainFolder"/clients/pls" "$PlsFolder"
  SynchLists $MainFolder"/clients/m3u" "$M3uFolder"

  log "----> STOP SYNCHONIZING PLAYLISTS FILES"


###### END MAIN FUNCTION ######

  else 
    log "------>No new files!"
  fi

  duration=$SECONDS;
  log "------>STOP (Duration: $(($duration / 60)) min $(($duration % 60)) secs.)"

  echo `date +%T --date="5 minutes"` > "$LogFolder/next_synch"
  sleep 5m

done
