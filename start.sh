#!/bin/bash
START=$(date +%s)

vagrant up --no-parallel

END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
