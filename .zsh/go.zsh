if (( $+commands[go] ))
then
  export PATH=$PATH:$(go env GOPATH)/bin
fi
