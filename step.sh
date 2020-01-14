#!/bin/bash
#

# Check for optional params

if [ -z "$add_bitrise_public_download_url" ]; then
	add_bitrise_public_download_url=true
fi

if [ -z "$add_bitrise_public_download_url" ]; then
	add_bitrise_public_download_url=true
fi

echo "pull request id: $pull_request_id"
echo "jira issue: $jira_issue"

if [ -z "$pull_request_id" ]; then
	echo "pull_request_id not set"
fi

if [ -z "$jira_issue" ]; then
	echo "jira_issue not set"
fi

# When either is unset
if [ -z "$pull_request_id" ] || [ -z "$jira_issue" ]; then
	# Check if this is merge commit
	if [[ $BITRISE_GIT_MESSAGE != *"Merge pull request"* ]]; then
		echo "This commit it's not a merge commit"
		exit -1
	fi

	# Extract JIRA issue identifier from commit message
	jira_issue=`echo $BITRISE_GIT_MESSAGE | egrep -o '[A-Z]+-[0-9]+' | head -n 1`

	if [ ! "$jira_issue" ]; then
		echo Commit message does not contain correct jira_issue
		exit -1
	fi

	# Extract Pull Request identifier from commit message
	pull_request_id=`echo $BITRISE_GIT_MESSAGE | egrep -o '[0-9]+' | head -n 1`

fi

repository_url=`echo "$GIT_REPOSITORY_URL" | sed 's/.git//g' | tr : /`
pull_request_url="https://$repository_url/pull/$pull_request_id"

# Generate comment body

comment_body="[Pull Request|$pull_request_url] for task $jira_issue was accepted.\nCan be tested using build: #$BITRISE_BUILD_NUMBER"
if $add_bitrise_public_download_url = true; then 
	comment_body="$comment_body\nDownload url: $BITRISE_PUBLIC_INSTALL_PAGE_URL"
fi

comment_body="$comment_body\n$extra_info_in_comment"

echo $comment_body
comment_url=$host/rest/api/2/issue/$jira_issue/comment
echo "$comment_url"
# add comment
curl -D- -o /dev/null -u $user:$api_token -X POST -H "Content-Type: application/json" -d "{\"body\": \"$comment_body\"}" $comment_url

transition_url=$host/rest/api/2/issue/$jira_issue/transitions
echo "$transition_url"
# move to ready for qa
res=$( curl -w %{http_code} -s --output /dev/null -D- -u $user:$api_token -X POST -H "Content-Type: application/json" -d "{\"transition\": {\"id\" : \"$qa_transition_id\"} }" $transition_url)

# if task was no_qa move directly to client
if [ "$res" != "204" ]; then
	curl -D- -o /dev/null -u $user:$api_token -X POST -H "Content-Type: application/json" -d "{\"transition\": {\"id\" : \"$no_qa_transition_id\"} }" $host/rest/api/2/issue/$jira_issue/transitions
fi
