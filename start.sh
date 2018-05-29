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
  if file --mime-type "$temp_file" | grep -q zip$; then
    echo "unziping file..."
    su -ls "/bin/bash" -c "unzip $temp_file" ace
  elif file --mime-type "$temp_file" | grep -q gzip$; then
    su -ls "/bin/bash" -c "tar xvf $temp_file" ace
  else
    su -ls "/bin/bash" -c "cp -p $temp_file ." ace
  fi
}

parse_args "$@"
groupmod -g $gid ace
usermod -u $uid -g $gid ace

if [ -d /home/ace/.config ]; then
  chown -R ace:ace /home/ace/.config
fi

/usr/bin/supervisord

if [ ! -z $torrent_url ]; then
  su -ls "/bin/bash" -c "mkdir /tmp/torrent/ && wget --directory-prefix=/tmp/torrent/ $torrent_url" ace
  extract_if_needed "/tmp/torrent/$(ls /tmp/torrent/)"
  torent_file="/home/ace/$(ls /home/ace | grep torrent$)"
fi

if [ ! -z $subtitle_url ]; then
  su -ls "/bin/bash" -c "mkdir /tmp/subtitle/ && wget --directory-prefix=/tmp/subtitle/ $subtitle_url" ace
  extract_if_needed "/tmp/subtitle/$(ls /tmp/subtitle/)"
  subtitles="--sub-file /home/ace/$(ls /home/ace | grep srt$)"
fi

# Wait until acestream engine started and listens on port.
while [ -z "`netstat -tln | grep 62062`" ]; do
  echo 'Waiting for acestream engine to start ...'
  sleep 1
done
echo 'Acestream engine started'
echo "mkdir -p /home/ace/.local/share; /usr/bin/acestreamplayer $subtitles $torent_file $acestream_url"
su -ls "/bin/bash" -c "mkdir -p /home/ace/.local/share; /usr/bin/acestreamplayer $subtitles $torent_file $acestream_url" ace
