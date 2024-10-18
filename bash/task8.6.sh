#!/bin/bash
find . -type f -mtime +7 -exec rm {} +
