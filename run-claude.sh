if [ -f ".env" ]; then
  set -a
  source .env
  set +a
fi


export SHELL=/bin/zsh

claude