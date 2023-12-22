#!/bin/bash

if [[ $1 == "watch" ]]; then
  # Watch for changes in i18n files, and update corresponding dart files
  flutter pub run build_runner watch --delete-conflicting-outputs
else
  # Build dart files from i18n.yaml files once
  flutter pub run build_runner build --delete-conflicting-outputs --release
fi
