alias dotgit='/usr/bin/git --git-dir=/home/ye/.cfg/ --work-tree=/home/ye'

# clash proxy
export http_proxy=http://$(hostname).local:7897
export https_proxy=http://$(hostname).local:7897
# ## 因为不知道其他哪个地方设置了 http_proxy，https_proxy
# ## 所以在这里删除
# unset http_proxy
# unset https_proxy
# unset HTTP_PROXY
# unset HTTPS_PROXY
