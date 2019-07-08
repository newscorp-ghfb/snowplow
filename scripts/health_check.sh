#!/bin/bash
sleep 60
curl localhost:5000/health | grep 'OK'
