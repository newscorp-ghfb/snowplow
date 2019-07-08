#!/bin/bash
if sudo fuser -k 5000/tcp; then
  echo "Previous collector app listening on port 5000 killed"
else
  echo "Nothing Listening on port 5000"
fi