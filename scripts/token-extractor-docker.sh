#!/bin/bash

bash <(curl -L https://github.com/PiotrMachowski/Xiaomi-cloud-tokens-extractor/raw/master/run_docker.sh) 

rm -f token_extractor_docker.zip
rm -fr token_extractor_docker