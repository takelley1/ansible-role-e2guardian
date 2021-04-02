#!/usr/bin/env sh
#
# Adds URLs/Domains in a text file to the specified E2Guardian list.
# This allows a user to easily add exceptions to E2Guardian without shell
#   access to the server.
#
# USAGE: ./edit-e2g-lists.sh {LIST_FILE}
#
# The list file format is:
# <FILE_PATH> <LINE_TO_ADD>
#
# Example list file:
# /opt/e2g/etc/e2guardian/lists/regexpurllist microsoft
# /opt/e2g/etc/e2guardian/lists/bannedsitelist youtube.com
#
# shellcheck disable=2094
set -eu

list="${1}"

printf "\n%s\n" "[$(date +%F_%T)] INFO: Starting edit-e2g-lists.sh, parsing ${list}"

# Remove whitespace from list file.
output_file="$(mktemp)"
awk '!/^$|^[[:space:]]*$/ {gsub(/[[:space:]]*$/,""); print $0}' "${list}" > "${output_file}"
mv -f -- "${output_file}" "${list}"

loop_index=0
output_file="$(mktemp)" # Create temporary output file.
# Begin looping through input file.
while read -r line; do

    # Keep track of loop index so we know which line to comment out after processing it.
    loop_index=$((loop_index+1))

    # Check to see if the current line is commented out.
    if [ -n "$(printf "%s\n" "${line}" | awk '!/^[[:space:]]*#|^$/ {print $0}')" ]; then

        # Clean up the current line further by removing trailing comments, extra spaces, etc.
        line_parsed="$(printf "%s\n" "${line}" | awk '{gsub(/^[[:space:]]/,"");gsub(/[[:space:]]$/,"");gsub(/#.*/,"");print $0}')"

        # If the line has the incorrect number of fields, print it unmodified to the output file and skip it.
        if [ "$(printf "%s\n" "${line_parsed}" | awk '{print NF}')" -ne 2 ]; then
            printf "%s\n" "[$(date +%F_%T)] WARNING: Skipping line \`${line}\` due to improper formatting!"
            awk -v loop_index="${loop_index}" '{if(NR==loop_index) print $0}' "${list}" >> "${output_file}"
            continue
        fi

        # Parse out fields from current line.
        path="$(printf "%s\n" "${line_parsed}" | awk '{print $1}')"
        line="$(printf "%s\n" "${line_parsed}" | awk '{print $2}')"

        if
            # Edit the file as specified by the first field of the current line.
            printf "\n%s\n%s\n" \
                "# Added by edit-e2guardian-list.sh on $(date +%F) at $(date +%T)" \
                "${line}" \
                >> "${path}"
        then
            printf "%s\n" "[$(date +%F_%T)] INFO: Adding \`${line}\` to \`${path}\`"

            # Comment out the current line after being processed by using its loop_index number.
            # Write to a separate output file so we're not writing to the same file we're reading in the loop.
            awk -v loop_index="${loop_index}" '{if(NR==loop_index) print "#"$0}' "${list}" >> "${output_file}"
        fi
    else
            # If current line is already commented, print it unmodified into the output file.
            awk -v loop_index="${loop_index}" '{if(NR==loop_index) print $0}' "${list}" >> "${output_file}"
    fi

done < "${list}"

# Check if anything changed.
if [ "$(cksum "${list}" | cut -f1 -d' ')" != "$(cksum "${output_file}" | cut -f1 -d' ')" ]; then

    # Replace input file with output file.
    mv -f -- "${output_file}" "${list}"

    printf "%s\n\n" "[$(date +%F_%T)] INFO: Restarting E2Guardian"

    if hash systemctl 2>"/dev/null"; then
        systemctl restart e2guardian
    elif hash service 2>"/dev/null"; then
        service e2guardian restart
    else
        printf "%s\n\n" "[$(date +%F_%T)] CRITICAL: No way to restart service!"
    fi
    printf "%s\n\n" "[$(date +%F_%T)] INFO: Done!"

else
    printf "%s\n\n" "[$(date +%F_%T)] INFO: Nothing to do!"
fi
