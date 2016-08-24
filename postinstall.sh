#!/usr/bin/env bash
cd ./node_modules/framerjs
npm install --only=dev
mkdir -p build
gulp webpack:release
cd ../..
gulp build
