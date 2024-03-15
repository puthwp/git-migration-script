#!/bin/bash
LINKS_FILE="./git_links.txt"
TEAM="Outlier-proj"
TEMP_DIR="migrate_temp"
export COLUMNS=$COLUMNS

header() {
    printf '%.0s=' {1..$COLUMNS}
    printf '%.0s*' {1..$COLUMNS}
    printf '%.0s=' {1..$COLUMNS}
}

sep() {
    printf '%.0s-' {1..$COLUMNS}
}

clone_old_repo() {
    url=$1
    repo=$2
    git clone $url $repo
    cd $repo
    ls
    git fetch --all
    git fetch --tags
    git pull --all
}

create_gh_repo() {
    repo=$1
    result=$(gh repo create $TEAM/$repo --private --source=. --remote=upstream --push 2>&1)
    echo $result
    # echo "result is $result"
    # return $?
    # echo $$
    # echo "https://github.com/Outlier-proj/$repo"
}

git_add_remote() {
    upstream=$1
    git remote rm origin
    git remote add upstream $1
}

push_everything() {
    git push upstream --all
    git push --tags
    # cd ..
}

repo_duplicate_name() {
    url=$1
    echo $url >> ../../error.txt
}

destroy_temp() {
    cd ..
    rm -rf ./$repo
}

if [ ! -d ./$TEMP_DIR ]; then
    mkdir ./$TEMP_DIR
    chmod a+x ./$TEMP_DIR
fi
cd $TEMP_DIR
while IFS= read -r url; do
    header
    repo=${url##*/}
    repo=${repo%.*}
    echo "Migrating...$repo"
    sep
    echo "Cloning..."
    clone_old_repo $url $repo
    sep
    echo "Creating GH Repo ..."
    new_repo=$(create_gh_repo $repo 2>&1)
    echo "$new_repo"

    if [[ $new_repo == *"createRepository"* ]]; then
        echo "###logging error repo###"
        repo_duplicate_name $url
    fi

    sep
    echo "Add New Remote"
    git_add_remote $upstream
    sep
    echo "Pushing everything ..."
    push_everything
    echo "$repo is Done"
    header
    cd ..
done < ../$LINKS_FILE
cd ..
# destroy_temp $repo


