#!/usr/bin/env bash

if [ -z "$(git status --untracked-files=no --porcelain)" ]; then echo 'clean'; else echo 'Uncommitted changes'; fi