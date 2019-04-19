# Txture backup script examples
This repository shows examples on how to backup your Txture instance.

## Concepts

The key concept is to activate the maintenance mode on your Txture instance before backing up the data. This ensures data integrity for the backup. This is achieved via a REST call to the API. Authentication to the REST endpoint happens via an API Token that can be [added in the admin area](https://txture.atlassian.net/wiki/spaces/SUP/pages/180060192/API+Tokens+View).

Once the maintenance mode has been activated, one has to ensure that it is actually active. Activation might be delayed by other processes which could lead to a delayed start of the maintenance mode and hence a corrupt backup.

## Implementations

Currently the following language implementations are available:
* Bash