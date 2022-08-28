#!/bin/bash -eu

# $1 = 削除するバケット名を指定する
if [ $# != 1 ]; then
    echo delete.sh bucket_name
    exit 1
fi

bucket_name=$1

# オブジェクトを削除する(再起的)
aws s3 rm s3://${bucket_name}/ --recursive

# 削除マーカを削除する
aws s3api list-object-versions --bucket ${bucket_name} \
        | jq -r -c '.["DeleteMarkers"][] | [.Key,.VersionId]' \
        | while read line
do
        key=`echo $line | jq -r .[0]`
        versionid=`echo $line | jq -r .[1]`
        aws s3api delete-object --bucket ${bucket_name} \
               --key ${key} --version-id ${versionid}
done

# 全バージョンを削除する
aws s3api list-object-versions --bucket ${bucket_name} \
        | jq -r -c '.["Versions"][] | [.Key,.VersionId]' \
        | while read line
do
        key=`echo $line | jq -r .[0]`
        versionid=`echo $line | jq -r .[1]`
        aws s3api delete-object --bucket ${bucket_name} \
               --key ${key} --version-id ${versionid}
done

# バケットを削除
aws s3api delete-bucket --bucket ${bucket_name}

echo $1 deleted.
