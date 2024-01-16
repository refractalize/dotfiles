git-pr-number() {
  GIT_BRANCH=$(git branch --show-current 2> /dev/null)

  if [[ $? -eq 0 ]]
  then
    GITHUB_PR_NUMBER=$(git config branch.$GIT_BRANCH.pr-number)

    if [[ -z $GITHUB_PR_NUMBER ]]
    then
      GITHUB_PR_NUMBER=$(gh pr view --json number --jq .number)
      git config branch.$GIT_BRANCH.pr-number $GITHUB_PR_NUMBER
    fi

    echo $GITHUB_PR_NUMBER
  else
    return 1
  fi
}

heroku-pr-app () {
  GITHUB_PR_NUMBER=$(git-pr-number)
  if [[ $? -eq 0 ]]
  then
    HEROKU_PR_APP=$HEROKU_PIPELINE-pr-$GITHUB_PR_NUMBER
    LBUFFER=${LBUFFER}$HEROKU_PR_APP
    echo $HEROKU_PR_APP
  else
    return 1
  fi
}

add-heroku-pr-app () {
  HEROKU_PR_APP=$(heroku-pr-app)
  if [[ $? -eq 0 ]]
  then
    LBUFFER=$LBUFFER$HEROKU_PR_APP
  else
    LBUFFER=$LBUFFER?
  fi
}
zle -N add-heroku-pr-app
