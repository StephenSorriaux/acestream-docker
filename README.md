## Usage

This a docker image that allow you to run acestreamplayer in order to play torrent file (optionnaly with subtitles) or acestream streams.

## Pull

    $ docker pull ssorriaux/acestreamplayer

## Build

    $ docker build -t ssorriaux/acestreamplayer https://github.com/StephenSorriaux/acestream-docker.git

## Run

    $ docker run -v /dev/snd:/dev/snd --privileged -v /tmp/.X11-unix:/tmp/.X11-unix -e uid=$(id -u) -e gid=$(id -g) -e DISPLAY=unix$DISPLAY --rm ssorriaux/acestreamplayer [PARAMETERS]

### Parameters

```
-tu TORRENT_URL, --torrent-url TORRENT_URL
                      URL to torrent file
-su SUBTITLE_URL, --subtitle-url SUBTITLE_URL
                      URL to subtitles file
-au ACESTREAM_URL, --acestream-url ACESTREAM_URL
                      URL to acestream stream
```

## Open acestream:// links in browser

    $ sudo cp ace.py /usr/local/bin/ace
    $ sudo chmod +x /usr/local/bin/ace
    $ sudo cp acestream.desktop /usr/share/applications/
    $ sudo update-desktop-database
