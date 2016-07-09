# ${1:Create-And-Share-Video-Playlists.sh}

It's easy BASH script to generate and upload playlists files (m3u, pls) to any linux device over rsync from existing video files with full log controll.

## Installation

1. Read below description
2. Download
3. chmod +x Create-And-Share-Video-Playlists.sh
4. Type "Create-And-Share-Video-Playlists.sh &"
5. Click ENTER :)

## Description

To fully use script you need to give access over http server (eg. Apache2) to local folder which will be used - HTTP server could use SSL with user/password access.

!!! Before using script prepare your HTTP server !!!

All what you need is enter local full directory path including videos to "VideoFolder" file, http prelink to "http_prelink" file (check examples below), give permission for user script to log folder ("/var/log/Create-And-Share-Video-Lists/") and recursive permission to video directory for the same user.

## How script works

1. Checks all depencies
2. Checks all necessary config files
3. Prepars variables
4. Checks availability of all necessary folders
5. Lists all files in Video folder
6. Removes old playlists folder (is exist)
7. Removes old logs files (older than 14 days)
8. Checks for changes (comparing old list file with new one)

(If there aren't any changes)
9. Saves in log that there weren't any changes
10. Saves in log duration of script
11. Waits 5 minutes and writes next time sync to /var/log/Create-And-Share-Video-Playlists/next_synch
12. (back to beginning)

(If changes took place)
9. Starts reading all video (*.avi, *.mkv, *.mp4) and prepares playlist files (.m3u, .pls) with all needs (time of movie, etc.)
10. Writing playlists file inside /var/log/Create-And-Share-Video-Playlists/actual_play_list
11. Synchronizes playlist files with remote device
12. Save in log duration of script
13. Waits 5 minutes and writes next time sync to /var/log/Create-And-Share-Video-Playlists/next_synch
14. (back to beginning)

## Synchronization

To synchronize files between local and remote machine you need to share SSH public keys to remote machine from user where script will be run.

## DEPENCIES

rsync
avconv

## EXAMPLES OF CONFIG FILES

"clients/m3u" (same as "clients/pls"):
user@192.168.123.123:/streaming/files/
anotheruser@172.16.222.111:/another/streaming/dir/

"VideoFolder":
/home/user/Videos/
/var/Videos/

"http_prelink":
http://example.com/dir/to/movies/
https://example.com/dir/to/movies/
https://user:password@example.com/dir/to/movies/

## EXAMPLE OF LOG FILE

00:03:36_------>START
00:03:36_Remote address: https://user:password@example.com/my/video/folder/
00:03:36_List folder: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/, Actual list file: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/list.00:03:36
00:03:36_Creating list folder: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/
00:03:36_Local video folder: /home/download/_DOWNLOADED/Wideo/
00:03:36_Generated movie list: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/list.00:03:36
00:03:36_Removed Old Logs File: /var/log/Create-And-Share-Video-Playlists//log.160625
00:03:36_Removed Old List Folder: /var/log/Create-And-Share-Video-Playlists/scanned_files/160625
00:03:36_------>No new files!
00:03:36_------>STOP (Duration: 0 min 0 secs.)
00:08:36_------>START
00:08:36_Remote address: https://user:password@example.com/my/video/folder/
00:08:36_List folder: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/, Actual list file: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/list.00:08:36
00:08:36_Local video folder: /home/download/_DOWNLOADED/Wideo/
00:08:36_Generated movie list: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/list.00:08:36
00:08:36_------>No new files!
00:08:36_------>STOP (Duration: 0 min 0 secs.)
.
.
.
14:12:13_------>START
14:12:13_Remote address: https://user:password@example.com/my/video/folder/
14:12:13_List folder: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/, Actual list file: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/list.14:12:13
14:12:13_Local video folder: /home/download/_DOWNLOADED/Wideo/
14:27:02_Generated movie list: /var/log/Create-And-Share-Video-Playlists/scanned_files/160709/list.14:12:13
14:27:02_------>Found new files!
14:27:02_Removed old playlists folder
14:27:02_----> START CONVERTING
.
.
.
14:28:21_---------> Processing FOR Eaters.2015.DVDRip.XviD.AC3-RARBG.avi
--PLS--> Localization: /var/log/Create-And-Share-Video-Playlists/actual_play_list/pls/English/Movies/2015/Eaters.2015.DVDRip.XviD.AC3-RARBG.avi.pls
--pls--> File1=https://user:password@example.com/my/video/folder/English/Movies/2015/Eaters.2015.DVDRip.XviD.AC3-RARBG.avi
--pls--> Title1=Eaters.2015.DVDRip.XviD.AC3-RARBG
--pls--> Lenght1=5403
--M3U--> Localization: /var/log/Create-And-Share-Video-Playlists/actual_play_list/m3u/English/Movies/2015/Eaters.2015.DVDRip.XviD.AC3-RARBG.avi.m3u
--m3u--> #EXTINF:5403,Eaters.2015.DVDRip.XviD.AC3-RARBG
--m3u--> https://user:password@example.com/my/video/folder/English/Movies/2015/Eaters.2015.DVDRip.XviD.AC3-RARBG.avi
14:30:20_---------> Processing FOR Lucky.Number.2015.HDRip.XviD.AC3-EVO.avi
--PLS--> Localization: /var/log/Create-And-Share-Video-Playlists/actual_play_list/pls/English/Movies/2015/Lucky.Number.2015.HDRip.XviD.AC3-EVO.avi.pls
--pls--> File1=https://user:password@example.com/my/video/folder/English/Movies/2015/Lucky.Number.2015.HDRip.XviD.AC3-EVO.avi
--pls--> Title1=Lucky.Number.2015.HDRip.XviD.AC3-EVO
--pls--> Lenght1=4776
--M3U--> Localization: /var/log/Create-And-Share-Video-Playlists/actual_play_list/m3u/English/Movies/2015/Lucky.Number.2015.HDRip.XviD.AC3-EVO.avi.m3u
--m3u--> #EXTINF:4776,Lucky.Number.2015.HDRip.XviD.AC3-EVO
--m3u--> https://user:password@example.com/my/video/folder/English/Movies/2015/Lucky.Number.2015.HDRip.XviD.AC3-EVO.avi
14:31:52_---------> Processing FOR Narcopolis.2015.BRRip.XviD.AC3-EVO.avi
.
.
.
14:47:22_----> STOP CONVERTING
14:47:22_----> Update last_scan
14:47:22_----> START SYNCHONIZING PLAYLIST FILES
14:47:22_Checking ip 172.16.10.1...
14:47:22_Client root@172.16.10.1 found!
14:47:22_--> START SYNCHRONIZING FOR 172.16.10.1 (root@172.16.10.1:/ON_LINE/)
14:47:28_SYNCHRONIZING FOR 172.16.10.1...
14:47:28_--> STOP SYNCHRONIZING FOR 172.16.10.1
14:47:28_Checking ip 172.16.10.2...
14:47:29_Client root@172.16.10.2 found!
14:47:29_--> START SYNCHRONIZING FOR 172.16.10.2 (root@172.16.10.2:/ON_LINE/)
14:47:51_SYNCHRONIZING FOR 172.16.10.2...
14:47:51_--> STOP SYNCHRONIZING FOR 172.16.10.2
14:47:51_Checking ip 172.16.10.3...
14:47:51_Client root@172.16.10.3 found!
14:47:51_--> START SYNCHRONIZING FOR 172.16.10.3 (root@172.16.10.3:/ON_LINE/)
14:48:14_SYNCHRONIZING FOR 172.16.10.3...
14:48:14_--> STOP SYNCHRONIZING FOR 172.16.10.3
14:48:14_Checking ip 172.16.10.4...
14:48:14_Client root@172.16.10.4 found!
14:48:14_--> START SYNCHRONIZING FOR 172.16.10.4 (root@172.16.10.4:/ON_LINE/)
14:48:15_Error while running rsync
14:48:15_--> STOP SYNCHRONIZING FOR 172.16.10.4
14:48:15_Checking ip 172.16.10.5...
14:48:18_172.16.10.5 NOT FOUND
14:48:18_Checking ip 172.16.10.6...
14:48:21_172.16.10.6 NOT FOUND
14:48:21_----> STOP SYNCHONIZING PLAYLISTS FILES
14:48:21_------>STOP (Duration: 36 min 8 secs.)
