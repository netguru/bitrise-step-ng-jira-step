# ng-jira-step

This bitrise step creates a comment for merges, posts them in correct ticket and moves ticket from Code Review column to QA or directly to Client/Done column if it's no_qa.


## How to use this Step

Add step definition. 
```YML
 comment:
    steps:
      - git::https://github.com/netguru/bitrise-step-ng-jira-step.git@master:
          title: ng-jira-step
          inputs:
            - host: $JIRA_HOST
            - user: $JIRA_USER
            - api_token: $JIRA_API_TOKEN
            - qa_transition_id: $JIRA_QA_TRANSACTION_ID
            - no_qa_transition_id: $JIRA_NO_QA_TRANSACTION_ID
```
Provide correct user and api token. 
To findout correct transtion id run 
```bash
curl -D- -u user:api_token -X GET JIRA_HOST/rest/api/2/issue/JIRA_ISSUE/transitions
```

As a $JIRA_ISSUE(format: XXX-1234) use id for the ticket that is currently in code review column
As a $JIRA_USER(format: xxxxx@x.x) use email address of the user which has sufficient privliges to the JIRA project.

## About

This project is made with <3 by [Netguru](https://netguru.co/opensource).

### License

Licensed under the MIT License. See [LICENSE.MD](LICENSE.MD) for more info.
