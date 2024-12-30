# gh-commited-prs

`gh-commited-prs` is a gh extension to list GitHub Pull Requests which include commits by specified author.

## Installation

```console
gh extension install tnagatomi/gh-commited-prs
```

## FLAGS

```
-h, --help     Show this help message
--author       Search by commit author (default to your system git user.email)
--from         Search commits from this date
--to           Search commits to date (default to today)
--exclude-head Specify head branch of Pull Requests to exclude
```

## Usage

List Pull Requests which include commits by you until today

```console
gh commited-prs --from 2024-07-01
```

List Pull Requests between specific dates

```console
gh commited-prs --from 2024-07-01 --to 2024-12-31
```

List Pull Requests by specific person (Can be email or name)

```console
gh commited-prs --author john@example.com --from 2024-07-01
```

List Pull Requests by excluding head branch (Useful for Gitflow alike to exclude release Pull Requests)

```console
gh commited-prs --from 2024-07-01 --exclude-head develop
```

## Limitation

- Squash merges and rebase merges are not supported
- It might take a while to process local git if specified date range's commit log is large
