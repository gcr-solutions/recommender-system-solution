#!/usr/bin/env python

import json

with open("config.json") as config:
    params = json.load(config)

print(" ".join(["{}={}".format(key, val) for key, val in params.items()]), end='')
