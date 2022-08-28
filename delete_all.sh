#!/bin/bash -eu

buckets=$(aws s3api list-buckets | jq -r '.Buckets[].Name')

for bucket in $buckets; do
        bash ${PWD}/delete.sh $bucket
done

echo all deleted.
