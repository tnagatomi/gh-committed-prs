# gh-committed-prs

`gh-committed-prs` is a gh extension to list pull requests which include commits by specified author.

## Installation

```
gh extension install tnagatomi/gh-committed-prs
```

## FLAGS

```
-h, --help     Show help message
--author       Search by commit author (default to your system git user.email)
--from         Search commits from this date
--to           Search commits to this date (default to today)
--exclude-head Specify head branch of pull requests to exclude
```

## Usage

You must be in the repository's git directory, and you must pull the repository before executing this command.

List pull requests which include commits by you until today:

```
gh committed-prs --from 2024-07-01
```

List pull requests between specific dates:

```
gh committed-prs --from 2024-07-01 --to 2024-12-31
```

List pull requests by specific commit author (can be email or name):

```
gh committed-prs --author john@example.com --from 2024-07-01
```

List pull requests by excluding head branch (useful for Gitflow alike to exclude release pull requests):

```
gh committed-prs --from 2024-07-01 --exclude-head develop
```

## Limitation

- Squash merge and rebase merge pull requests are not supported
- It might take a while to process local git if specified date range's commit log is large
