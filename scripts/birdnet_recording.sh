#!/usr/bin/env bash

# This script is used to record audio from a microphone or RTSP stream
# and save it to a directory.

# You can specify the recording length in seconds by setting the
# RECORDING_LENGTH variable in birdnet.conf. If you do not specify a
# recording length, the default is 15 seconds.

# If you are recording from a microphone, you can specify the recording
# card by setting the REC_CARD variable in birdnet.conf. If you do not
# specify a recording card, the default is the first available card.

# Will record from a microphone if RTSP_STREAM is not set in birdnet.conf

# Recordings are saved in the following format:
# /path/to/recordings/January-2020/01-Sunday/2020-01-01-birdnet-00:00:00.wav
# The path to the recordings is set in birdnet.conf by the RECS_DIR variable.
# If the directory does not exist, it will be created.


set -x
source /etc/birdnet/birdnet.conf

[ -z $RECORDING_LENGTH ] && RECORDING_LENGTH=15

if [ ! -z $RTSP_STREAM ];then
  [ -d $RECS_DIR/StreamData ] || mkdir -p $RECS_DIR/StreamData
  while true;do
    for i in ${RTSP_STREAM//,/ };do
      ffmpeg -nostdin -i  ${i} -t ${RECORDING_LENGTH} -vn -acodec pcm_s16le -ac 2 -ar ${SAMPLING_RATE} file:${RECS_DIR}/StreamData/$(date "+%F")-birdnet-$(date "+%H:%M:%S").wav
    done
  done
else
  if ! pulseaudio --check;then pulseaudio --start;fi
  if pgrep arecord &> /dev/null ;then
    echo "Recording"
  else
    # until grep 5050 <(netstat -tulpn 2>&1);do
    #   sleep 1
    # done
    if [ -z ${REC_CARD} ];then
      arecord -f S16_LE -c${CHANNELS} -r${SAMPLING_RATE} -t wav --max-file-time ${RECORDING_LENGTH}\
	      --use-strftime ${RECS_DIR}/%B-%Y/%d-%A/%F-birdnet-%H:%M:%S.wav
    else
      arecord -f S16_LE -c${CHANNELS} -r${SAMPLING_RATE} -t wav --max-file-time ${RECORDING_LENGTH}\
        -D "${REC_CARD}" --use-strftime \
	${RECS_DIR}/%B-%Y/%d-%A/%F-birdnet-%H:%M:%S.wav
    fi
  fi
fi
