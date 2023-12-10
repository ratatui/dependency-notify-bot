#!/usr/bin/env bash

set -e

file="dependents.txt"
dependents=()
# WEBHOOK_URL=""
# REPO=""

notify() {
	curl -X POST -H "Content-Type: application/json" -d '{
    	"content": "```diff\n'"${1//$'\n'/\\n}"'\n```"
	}' "${WEBHOOK_URL}"
}

readarray -t dependents <<<$(bin/github-dependents-info --repo "${REPO}" --json | jq -r .all_public_dependent_repos[].name)

printf "%s\n" "${dependents[@]}" >"${file}"

diff_result=$(diff -u "old_${file}" "${file}" | tail -n +4 | awk '$1 ~ /^+|^-/' | sed -E "s/^(\+|-)/\1 https:\/\/github.com\//g")

if [ -n "${diff_result}" ]; then
	notify "${diff_result}"
fi

printf "%s\n" "${dependents[@]}" >"old_${file}"
