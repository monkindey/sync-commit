#!/bin/sh

# https://stackoverflow.com/a/12973694
# trim the left whitespace because of the git log --author= 'xxxx'
# can't work and throw the ambiguous argument error

getConfig() {
    cat config.json | grep $1 | cut -d ':' -f2,3 | sed 's/"\(.*\)",*$/\1/' | xargs
}

fromPath="`getConfig from | cut -d ':' -f1`"
fromBranch=`getConfig from | cut -d ':' -f2`
author=`getConfig author | cut -d ':' -f1`
since=`getConfig since | cut -d ':' -f1`
toPath=`getConfig to | cut -d ':' -f1`
toBranch=`getConfig to | cut -d ':' -f2`

if [ "$since" == '' ]
then 
    since=3
fi

cd $toPath

if [ $(git rev-parse --abbrev-ref HEAD) != "$toBranch" ]
then
    git checkout $toBranch
fi

cd $fromPath

if [ $(git rev-parse --abbrev-ref HEAD) != "$fromBranch" ]
then
    git checkout $fromBranch
fi

rsync -R \
    `git log --no-merges \
    --name-only \
    --author=$author \
    --since="$since days ago" \
    --oneline \
    | grep -E \.[a-z]+$ \
    | sort \
    | uniq \
    | tr '\n' ' '` \
    $toPath