source $HOME/.proxyenv

alias dgit='/usr/bin/git --git-dir=/home/ye/.cfg/ --work-tree=/home/ye'

# nvm mirror
## https://mirrors.tuna.tsinghua.edu.cn/help/nodejs-release/
export NVM_NODEJS_ORG_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/

# pnpm
export PNPM_HOME="/home/ye/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end