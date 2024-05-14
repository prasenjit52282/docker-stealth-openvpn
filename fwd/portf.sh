#!/bin/sh -e

python3 forward.py --mode socks &
python3 forward.py --mode ssh &
python3 forward.py --mode wsock &

wait