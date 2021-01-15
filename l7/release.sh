#!/bin/bash
if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "GITHUB_TOKEN environment variable must be set for this script!"
  exit 0
else
  GITHUB_TOKEN="${GITHUB_TOKEN}"
fi

if [[ -z "${GITHUB_USER}" ]]; then
  echo "GITHUB_USER environment variable must be set for this script!"
  exit 0
else
  GITHUB_USER="${GITHUB_USER}"
fi

#================================
#================================
token=$GITHUB_TOKEN
repo=cloudacademy/devsecops-lab
#================================
#================================

BASE_STRING=`cat VERSION`
BASE_LIST=(`echo $BASE_STRING | tr '.' ' '`)
V_MAJOR=${BASE_LIST[0]}
V_MINOR=${BASE_LIST[1]}
V_PATCH=${BASE_LIST[2]}
echo "Current version : $BASE_STRING"
V_MINOR=0
V_PATCH=$((V_PATCH + 1))
SUGGESTED_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
read -p "Enter a version number [$SUGGESTED_VERSION]: " INPUT_STRING
if [ "$INPUT_STRING" = "" ]; then
     INPUT_STRING=$SUGGESTED_VERSION
fi
echo "Will set new version to be $INPUT_STRING"
echo $INPUT_STRING > VERSION

git add VERSION
git commit -m "Version bump to $INPUT_STRING"
git push origin

VERSION=`cat VERSION`

echo ==============================
find . -name .DS_Store -type f -delete
find . -name .project -type f -delete
find . -name .classpath -type f -delete
rm -rf `find . -name .settings -type d`
rm -rf `find . -name target -type d`
tree -a
zip -r code-$VERSION.zip code
echo ==============================
echo

echo latest release = code-$VERSION.zip
ls -la
echo ==============================
echo

read -p "Press [Enter] key to start release upload..."

upload_url=$(curl -s -u $GITHUB_USER:$GITHUB_TOKEN \
     --request POST \
     --url https://api.github.com/repos/$repo/releases \
     --data '{"tag_name": "release-'$VERSION'", "name":"release-'$VERSION'","body":"release '$VERSION'"}' \
     | jq -r '.upload_url')

upload_url="${upload_url%\{*}"

echo "uploading asset to release url : $upload_url"
echo

curl -s -u $GITHUB_USER:$GITHUB_TOKEN \
        -H "Content-Type: application/zip" \
        --data-binary @code-$VERSION.zip  \
        "$upload_url?name=code-$VERSION.zip&label=code-$VERSION.zip"

echo ==============================

echo
echo "uploading release complete!!"
echo