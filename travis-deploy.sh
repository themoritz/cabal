#!/bin/sh
set -ex

setup() {
    git clone https://github.com/haskell/cabal-website.git ../cabal-website
    cd ../cabal-website
    openssl aes-256-cbc -K $encrypted_edaf6551664d_key \
            -iv $encrypted_edaf6551664d_iv \
            -in id_rsa_cabal_website.aes256.enc -out id_rsa -d
    mv id_rsa ~/.ssh/id_rsa
    chmod 400 ~/.ssh/id_rsa
    git checkout --track -b gh-pages origin/gh-pages
    cd -
}

deploy() {
    git config --global user.email "builds@travis-ci.org"
    git config --global user.name "Travis CI User"
    mkdir -p ../cabal-website/doc/html
    mv Cabal/dist/doc/html/Cabal ../cabal-website/doc/html/Cabal
    cd ../cabal-website
    git add --all .
    git commit --amend --reset-author -m "Deploy to GitHub ($(date))."
    git push --force git@github.com:haskell/cabal-website.git gh-pages:gh-pages
}

if [ "x$TRAVIS_PULL_REQUEST" = "xfalse" -a "x$TRAVIS_BRANCH" = "xmaster" \
                             -a "x$DEPLOY_DOCS" = "xYES" ]
then
    case "${1}" in
        "setup")
            setup
            ;;
        "deploy")
            deploy
            ;;
        *)
            echo Unknown command!
            ;;
    esac
fi