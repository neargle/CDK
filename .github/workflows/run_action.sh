set -x 

date_string=`date -u +"%d%H%M"`
tag_name="v1.0.1.changelog-${date_string}"

git push origin

git tag "$tag_name"
git push origin "$tag_name"
