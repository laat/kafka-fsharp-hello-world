#!/usr/bin/env bash
# shellcheck disable=SC2120
function log {
    echo
    echo "####"
    echo "#### " "$@"
    echo "####"
    echo
}

function log_run {
    log "$@"
    "$@"
}

function ensure_solution {
    solution=(./*.sln)
    if [ ! -f "${solution[0]}" ]; then
        log_run dotnet new sln
    fi
}

function ensure_tool_manifest {
    if [ ! -f ".config/dotnet-tools.json" ]; then
        log_run dotnet new tool-manifest
    fi
}

# the latest known wokring version.
# 5.241.6 does not work somehow :/
PAKET_VERSION=${PAKET_VERSION:-"5.234.1"}

function install_paket {
    ensure_tool_manifest

    local VERSION=${1:-"$PAKET_VERSION"}

    log_run dotnet tool install paket --version "$VERSION"
    log_run dotnet tool restore
    log_run dotnet paket init
}
function ensure_paket {
    ensure_tool_manifest
    if ! dotnet paket --version > /dev/null 2>&1 ; then
        install_paket "$@"
    fi
}

function has_paket_dependency {
    local project=$1
    local dependency=$2
    dotnet paket show-installed-packages --project "src/$project/$project.fsproj" | grep "Main $dependency -" &> /dev/null
}

function add_paket_dependency {
    ensure_paket

    local project=$1
    local dependency=$2

    if ! has_paket_dependency "$project" "$dependency" ; then
        log_run dotnet paket add "$dependency" --project "src/$project/$project.fsproj"
    fi

}

function fsharp_project {
    ensure_solution
    ensure_paket

    local type=$1
    local project=$2
    shift
    shift

    if [ ! -d "src/$project" ]; then
        log_run dotnet new "$type" -lang F# -o "src/$project"
        log_run dotnet sln add "src/$project"
        add_paket_dependency "$project" FSharp.Core
    fi

    for dep in "$@"
    do
        add_paket_dependency "$project" "$dep"
    done

}