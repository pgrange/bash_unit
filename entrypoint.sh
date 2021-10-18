#!/bin/sh
set -e

#/*
# * This script is based on TangoMan Shoe Shell Microframework version 0.1.0-xs
# *
# * This file is distributed under to the MIT license.
# *
# * Copyright (c) 2021 "Matthias Morin" <mat@tangoman.io>
# *
# * Permission is hereby granted, free of charge, to any person obtaining a copy
# * of this software and associated documentation files (the "Software"), to deal
# * in the Software without restriction, including without limitation the rights
# * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# * copies of the Software, and to permit persons to whom the Software is
# * furnished to do so, subject to the following conditions:
# *
# * The above copyright notice and this permission notice shall be included in all
# * copies or substantial portions of the Software.
# *
# * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# * SOFTWARE.
# *
# * Source code is available here: https://github.com/TangoMan75/shoe
# */

#/**
# * Bash Unit CI Pipeline Manager
# *
# * This script runs continuous integration pipeline for bash_unit
# *
# * @author  "Matthias Morin" <mat@tangoman.io>
# * @version 0.1.0
# * @link    https://github.com/pgrange/bash_unit
# */

## Install git hooks
hooks() {
    echo_info 'rm -fr .git/hooks\n'
    rm -fr .git/hooks

    echo_info 'cp -r .githooks .git/hooks\n'
    cp -r .githooks .git/hooks

    echo_info 'chmod +x .git/hooks/*\n'
    chmod +x .git/hooks/*
}

## Sniff errors with linter
lint() {
    if [ ! -x "$(command -v shellcheck)" ]; then
        echo_error "\"$(basename "${0}")\" requires shellcheck, try: 'sudo apt-get install -y shellcheck'\n"
        exit 1
    fi

    for FILE in \
        ./bash_unit \
        ./entrypoint.sh \
        ./install.sh \
        ./tests/test_cli.sh \
        ./tests/test_core.sh \
        ./tests/test_doc.sh \
        ./tests/test_tap_format.sh \
    ; do
        echo_info "shellcheck \"${FILE}\"\n"
        shellcheck "${FILE}"
    done
}

## Run tests
tests() {
    for FILE in \
        ./tests/test_cli.sh \
        ./tests/test_tap_format.sh \
        ./tests/test_doc.sh \
        ./tests/test_core.sh \
    ; do
        echo_info "./bash_unit \"${FILE}\"\n"
        ./bash_unit  "${FILE}"

        echo_info "./bash_unit -f tap \"${FILE}\"\n"
        ./bash_unit -f tap  "${FILE}"
    done
}

## Run tests in AmazonLinux Docker container
amazonlinux() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" amazonlinux ./entrypoint.sh tests\n"
    docker run --rm --volume="$(pwd):/home:ro" --workdir="/home" amazonlinux ./entrypoint.sh tests
}

## Run tests in AmazonLinux Docker container with tty
amazonlinux_tty() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run -it --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" amazonlinux ./entrypoint.sh tests\n"
    docker run -it --rm --volume="$(pwd):/home:ro" --workdir="/home" amazonlinux ./entrypoint.sh tests
}

## Run tests in ArchLinux Docker container
archlinux() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" archlinux ./entrypoint.sh tests\n"
    docker run --rm --volume="$(pwd):/home:ro" --workdir="/home" archlinux ./entrypoint.sh tests
}

## Run tests in ArchLinux Docker container with tty
archlinux_tty() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run -it --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" archlinux ./entrypoint.sh tests\n"
    docker run -it --rm --volume="$(pwd):/home:ro" --workdir="/home" archlinux ./entrypoint.sh tests
}

## Run tests in Debian Linux Docker container
debian() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" debian ./entrypoint.sh tests\n"
    docker run --rm --volume="$(pwd):/home:ro" --workdir="/home" debian ./entrypoint.sh tests
}

## Run tests in Debian Linux Docker container with tty
debian_tty() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run -it --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" debian ./entrypoint.sh tests\n"
    docker run -it --rm --volume="$(pwd):/home:ro" --workdir="/home" debian ./entrypoint.sh tests
}

## Run tests in MacOS Docker container
macos() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run -it --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" macos ./entrypoint.sh tests\n"
    docker run -it --rm --volume="$(pwd):/home:ro" --workdir="/home" macos ./entrypoint.sh tests
}

## Run tests in OracleLinux Docker container
oraclelinux() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" oraclelinux:8-slim ./entrypoint.sh tests\n"
    docker run --rm --volume="$(pwd):/home:ro" --workdir="/home" oraclelinux:8-slim ./entrypoint.sh tests
}

## Run tests in OracleLinux Docker container with tty
oraclelinux_tty() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run -it --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" oraclelinux:8-slim ./entrypoint.sh tests\n"
    docker run -it --rm --volume="$(pwd):/home:ro" --workdir="/home" oraclelinux:8-slim ./entrypoint.sh tests
}

## Run tests in Ubuntu Linux Docker container
ubuntu() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" ubuntu ./entrypoint.sh tests\n"
    docker run --rm --volume="$(pwd):/home:ro" --workdir="/home" ubuntu ./entrypoint.sh tests
}

## Run tests in Ubuntu Linux Docker container with tty
ubuntu_tty() {
    if [ ! -x "$(command -v docker)" ]; then
        echo_error "\"$(basename "${0}")\" requires docker, try 'sudo apt-get install -y docker.io'\n"
        return 1
    fi

    echo_info "docker run -it --rm --volume=\"$(pwd):/home:ro\" --workdir=\"/home\" ubuntu ./entrypoint.sh tests\n"
    docker run -it --rm --volume="$(pwd):/home:ro" --workdir="/home" ubuntu ./entrypoint.sh tests
}

#--------------------------------------------------

# shellcheck disable=SC2034
{
    PRIMARY='\033[97m'; SECONDARY='\033[94m'; SUCCESS='\033[32m'; DANGER='\033[31m'; WARNING='\033[33m'; INFO='\033[95m'; LIGHT='\033[47;90m'; DARK='\033[40;37m'; DEFAULT='\033[0m'; NL='\033[0m\n';
    ALERT_PRIMARY='\033[1;104;97m'; ALERT_SECONDARY='\033[1;45;97m'; ALERT_SUCCESS='\033[1;42;97m'; ALERT_DANGER='\033[1;41;97m'; ALERT_WARNING='\033[1;43;97m'; ALERT_INFO='\033[1;44;97m'; ALERT_LIGHT='\033[1;47;90m'; ALERT_DARK='\033[1;40;37m';
}

echo_primary()   { printf "%b%b${DEFAULT}" "${PRIMARY}"   "${*}"; }
echo_secondary() { printf "%b%b${DEFAULT}" "${SECONDARY}" "${*}"; }
echo_success()   { printf "%b%b${DEFAULT}" "${SUCCESS}"   "${*}"; }
echo_danger()    { printf "%b%b${DEFAULT}" "${DANGER}"    "${*}"; }
echo_warning()   { printf "%b%b${DEFAULT}" "${WARNING}"   "${*}"; }
echo_info()      { printf "%b%b${DEFAULT}" "${INFO}"      "${*}"; }
echo_light()     { printf "%b%b${DEFAULT}" "${LIGHT}"     "${*}"; }
echo_dark()      { printf "%b%b${DEFAULT}" "${DARK}"      "${*}"; }

echo_label()     { if [ $# -eq 2 ]; then printf "%b%-${1}s ${DEFAULT}" "${SUCCESS}" "$2"; else printf "%b%b ${DEFAULT}" "${SUCCESS}" "${*}"; fi }
echo_error()     { printf "%berror: %b${DEFAULT}" "${DANGER}"  "${*}"; }

alert_primary()   { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_PRIMARY}"   '' "${ALERT_PRIMARY}"   "${*}" "${ALERT_PRIMARY}"   ''; }
alert_secondary() { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_SECONDARY}" '' "${ALERT_SECONDARY}" "${*}" "${ALERT_SECONDARY}" ''; }
alert_success()   { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_SUCCESS}"   '' "${ALERT_SUCCESS}"   "${*}" "${ALERT_SUCCESS}"   ''; }
alert_danger()    { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_DANGER}"    '' "${ALERT_DANGER}"    "${*}" "${ALERT_DANGER}"    ''; }
alert_warning()   { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_WARNING}"   '' "${ALERT_WARNING}"   "${*}" "${ALERT_WARNING}"   ''; }
alert_info()      { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_INFO}"      '' "${ALERT_INFO}"      "${*}" "${ALERT_INFO}"      ''; }
alert_light()     { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_LIGHT}"     '' "${ALERT_LIGHT}"     "${*}" "${ALERT_LIGHT}"     ''; }
alert_dark()      { printf "${NL}%b%64s${NL}%b %-63s${NL}%b%64s${NL}\n" "${ALERT_DARK}"      '' "${ALERT_DARK}"      "${*}" "${ALERT_DARK}"      ''; }

#--------------------------------------------------

## Print this help (default)
help() {
    alert_primary 'Bash Unit CI Pipeline Manager'

    echo_warning 'Infos:\n'
    echo_label 10 '  author';  echo_primary '"Matthias Morin" <mat@tangoman.io>\n'
    echo_label 10 '  version'; echo_primary '0.1.0\n'
    echo_label 10 '  link';    echo_primary 'https://github.com/pgrange/bash_unit\n\n'

    echo_warning 'Description:\n'
    echo_primary '  This script runs continuous integration pipeline for bash_unit\n\n'

    echo_warning 'Usage:\n'
    echo_success '  sh entrypoint.sh '
    echo_secondary '['
    echo_warning 'command'
    echo_secondary ']\n\n'

    echo_warning 'Commands:\n'
    echo_label 15 '  hooks';           echo_primary 'Install git hooks\n'
    echo_label 15 '  lint';            echo_primary 'Sniff errors with linter\n'
    echo_label 15 '  tests';           echo_primary 'Run tests\n'
    echo_label 15 '  amazonlinux';     echo_primary 'Run tests in AmazonLinux Docker container\n'
    echo_label 15 '  amazonlinux_tty'; echo_primary 'Run tests in AmazonLinux Docker container with tty\n'
    echo_label 15 '  archlinux';       echo_primary 'Run tests in ArchLinux Docker container\n'
    echo_label 15 '  archlinux_tty';   echo_primary 'Run tests in ArchLinux Docker container with tty\n'
    echo_label 15 '  debian';          echo_primary 'Run tests in Debian Docker container\n'
    echo_label 15 '  debian_tty';      echo_primary 'Run tests in Debian Docker container with tty\n'
    echo_label 15 '  macos';           echo_primary 'Run tests in MacOS Docker container\n'
    echo_label 15 '  oraclelinux';     echo_primary 'Run tests in OracleLinux Docker container\n'
    echo_label 15 '  oraclelinux_tty'; echo_primary 'Run tests in OracleLinux Docker container with tty\n'
    echo_label 15 '  ubuntu';          echo_primary 'Run tests in Ubuntu Linux Docker container\n'
    echo_label 15 '  ubuntu_tty';      echo_primary 'Run tests in Ubuntu Linux Docker container with tty\n'
    echo_label 15 '  help';            echo_primary 'Print this help (default)\n\n'
}

#--------------------------------------------------

_main() {
    if [ $# -lt 1 ]; then
        help
        exit 0
    fi



    for ARGUMENT in "$@"; do
        case ${ARGUMENT} in
            hooks)           hooks;;
            lint)            lint;;
            tests)           tests;;
            amazonlinux)     amazonlinux;;
            amazonlinux_tty) amazonlinux_tty;;
            archlinux)       archlinux;;
            archlinux_tty)   archlinux_tty;;
            debian)          debian;;
            debian_tty)      debian_tty;;
            macos)           macos;;
            oraclelinux)     oraclelinux;;
            oraclelinux_tty) oraclelinux_tty;;
            ubuntu)          ubuntu;;
            ubuntu_tty)      ubuntu_tty;;
            help)            help;;
            *) echo_danger "error: \"$1\" is not a valid command\n";
            exit 1;;
        esac
    done

}

_main "$@"
