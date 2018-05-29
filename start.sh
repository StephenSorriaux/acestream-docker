#!/bin/bash

#abort on error
set -e

function usage
{
    echo "usage: start.sh [-tu TORRENT_URL || -su SUBTITLE_URL || -au ACESTREAM_URL || -h] STREAM"
    echo "   ";
    echo "  -tu | --torrent-url            : URL to torrent file";
    echo "  -su | --subtitle-url           : URL to subtitles";
    echo "  -su | --subtitle-url           : URL to subtitles";
    echo "  -h | --help                   : This message";
}

function parse_args
{
  # positional args
  args=()

  # named args
  while [ "$1" != "" ]; do
      case "$1" in
          -tu | --torrent-url )               torrent_url="$2";             shift;;
          -su | --subtitle-url )              subtitle_url="$2";            shift;;
          -au | --acestream-url )             acestream_url="$2";           shift;;
          -h | --help )                      usage;                         exit;; # quit and show usage
          * )                                args+=("$1")             # if no match, add it to the positional args
      esac
      shift # move to next kv pair
  done

  # restore positional args
  set -- "${args[@]}"

}

function extract_if_needed
{
  temp_file=$1
  extract_file=$2
  if file --mime-type "$temp_file" | grep -q zip$; then
    echo "unziping file..."
    unzip $temp_file -d $extract_file
  elif file --mime-type "$temp_file" | grep -q gzip$; then
    tar xvf $temp_file -C $extract_file
  else
    cp -p $temp_file $extract_file
  fi
}

parse_args "$@"

# Start the first process
nohup /usr/bin/acestreamengine --bind-all --client-console &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start acestreamengine: $status"
  exit $status
fi

if [ ! -z $torrent_url ]; then
  mkdir -p /tmp/torrent/ /tmp/vlc/ && wget --directory-prefix=/tmp/torrent/ $torrent_url
  extract_if_needed "/tmp/torrent/$(ls /tmp/torrent/)" "/tmp/vlc/"
  torent_file="/tmp/vlc/$(ls /tmp/vlc | grep torrent$)"
fi

if [ ! -z $subtitle_url ]; then
  mkdir -p /tmp/subtitle/ /tmp/vlc && wget --directory-prefix=/tmp/subtitle/ $subtitle_url
  extract_if_needed "/tmp/subtitle/$(ls /tmp/subtitle/)" "/tmp/vlc"
  subtitles="--sub-file /tmp/vlc/$(ls /tmp/vlc | grep srt$)"
fi

# Wait until acestream engine started and listens on port.
while [ -z "`netstat -tln | grep 62062`" ]; do
  echo 'Waiting for acestream engine to start ...'
  sleep 1
done
echo 'Acestream engine started'

/usr/bin/acestreamplayer $subtitles $torent_file $acestream_url
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start acestreamplayer: $status"
  exit $status
fi
