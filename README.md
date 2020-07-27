# ffmpeg-x11grab-container
A fedora-based container for ffmpeg, that can be used to do screen capture.
Compiled with h264 support only; no sound capture.

## Example use

podman run --privileged --net host -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:$HOME -e HOME=$HOME -e DISPLAY=$DISPLAY --rm -it ffmpeg-x11grab:fedora -f x11grab -video_size 1280x720 -i ${DISPLAY} -vcodec h264 -framerate 25 $HOME/screencast.mp4
