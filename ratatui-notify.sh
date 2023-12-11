#!/usr/bin/env bash

set -e

file="$(basename "$REPO").txt"
dependents=()
# WEBHOOK_URL=""
# REPO=""

notify() {
	msg="**$REPO** dependents:\n$1"
	curl -X POST -H "Content-Type: application/json" -d '{
    	"content": "```diff\n'"${msg//$'\n'/\\n}"'\n```"
	}' "${WEBHOOK_URL}"
}

readarray -t dependents <<<$(github-dependents-info --verbose --repo "${REPO}" --json | jq -r .all_public_dependent_repos[].name)

printf "%s\n" "${dependents[@]}" >"${file}"

diff_result=$(diff -u "old_${file}" "${file}" | tail -n +4 | awk '$1 ~ /^+|^-/' | sed -E "s/^(\+|-)/\1 https:\/\/github.com\//g")

if [ -n "${diff_result}" ]; then
	notify "${diff_result}"
fi

printf "%s\n" "${dependents[@]}" >"old_${file}"
