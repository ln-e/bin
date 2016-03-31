### install packages on mac
#brew install libav
#brew install qtfaststart or brew install libav-tools


avconv -i ${1} -vcodec libx264 pre_out.mp4
qt-faststart pre_out.mp4 ${2}
rm pre_out.mp4
