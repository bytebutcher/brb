#!/bin/bash
# ##################################################
# NAME:
#   brb
# DESCRIPTION:
#   be right bash - yet another bash bookmark script
# AUTHOR:
#   bytebutcher
# ##################################################

function usage() {
	echo "usage: $(basename $0) [-a] [-r] [-l]>"	>&2
	echo "  -a  add current dir to bookmarks" 	>&2
	echo "  -r  remove current dir from bookmarks"	>&2
	echo "  -l  list bookmarks"			>&2
	echo "  -?  display help"			>&2
	exit 1
}

function require_command() {
	local required_command="${1}"
	command -v "${required_command}" >/dev/null 2>&1 || {
		echo "Require ${required_command} but it's not installed. Aborting." >&2
		exit 1;
	}
}

function is_integer() {
	[[ ${1} =~ ^[0-9]+$ ]]
}

function resolve_dir() {
	cd "$1" 2>/dev/null || return $?  
	echo "`pwd -P`" 
}

function add_bookmark() {
	if ! grep "^${1}\$" "${BOOKMARK_FILE}" ; then
		echo "$1" | tee -a "${BOOKMARK_FILE}"
	fi
}

function get_bookmark_by_index() {
	local index="${1}"; 
	local line_count="$(wc -l "${BOOKMARK_FILE}" | awk '{ print $1 }')"
	if ! is_integer ${index} || [ ${index} -eq 0 ] || [ ${index} -gt ${line_count} ] ; then
		echo "ERROR: Invalid index!" >&2
		exit 1
	fi
	sed "${index}q;d" "${BOOKMARK_FILE}"
}

function remove_bookmark() {
	if [ -f "${BOOKMARK_FILE}" ] ; then
		local tmp_file=$(mktemp)
		grep -v "^${1}\$" <"${BOOKMARK_FILE}" >"${tmp_file}"
		mv "${tmp_file}" "${BOOKMARK_FILE}"
		echo "${1}"
	fi
}

function remove_bookmark_by_index() {
	if [ -f "${BOOKMARK_FILE}" ] ; then
		local index="${1}"
		remove_bookmark $(get_bookmark_by_index ${index})
	fi
}

function list_bookmarks () {
	if [ -f "${BOOKMARK_FILE}" ] ; then
		cat -n "${BOOKMARK_FILE}"
	fi
}

CURRENT_PATH=$(resolve_dir "${CWD}")
BOOKMARK_PATH="${HOME}/.brb/"
BOOKMARK_NAME="bookmarks"
BOOKMARK_FILE="${BOOKMARK_PATH}${BOOKMARK_NAME}"

require_command "fzf"

if ! [ -d "${BOOKMARK_PATH}" ] ; then
	mkdir "${BOOKMARK_PATH}"
fi

if [ $# -eq 0 ] ; then
	if [ -f "${BOOKMARK_FILE}" ] ; then
		cat "${BOOKMARK_FILE}" | fzf
	else
		echo "No bookmarks defined yet." >&2
	fi
	exit 0
fi

case $1 in
	-a | --add)
		add_bookmark "${CURRENT_PATH}"
		exit 0
		;;
	-r | --remove)
		index="$2"
		if [ -z "${index}" ] ; then
			remove_bookmark "${CURRENT_PATH}"
		else
			remove_bookmark_by_index "${index}"
		fi
		exit 0
		;;
	-l | --list)
		list_bookmarks 
		exit 0
		;;
	-h | --help )
		usage
		exit 0
		;;
	* )
		if is_integer "${1}" ; then
			index="${1}"
			get_bookmark_by_index "${index}"
		else
			usage
			exit 1
		fi
esac