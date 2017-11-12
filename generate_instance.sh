#!/bin/bash 

###############################################################
# This script generates Parity Game at random with "pgsolver" #
# then, translates into Mean Payoff Game with "bin/pg2mpg"    #
###############################################################

PG_WRITE_TO_FILE="data/random_pg"
NUM_NODES=$1
MAX_WEIGHT=$2
MAX_PRIORITY=$2
MIN_DEG=1
MAX_DEG=$1

pgsolver/bin/randomgame $NUM_NODES $MAX_PRIORITY $MIN_DEG $MAX_DEG > $PG_WRITE_TO_FILE
bin/pg2mpg $PG_WRITE_TO_FILE $MAX_WEIGHT
