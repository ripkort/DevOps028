#!/usr/bin/env python3
import sys
import boto3
import botocore
import threading

class ProgressPercentage(object):
    def __init__(self, filename):
        self._filename = filename
        self._seen_so_far = 0
        self._lock = threading.Lock()
    def __call__(self, bytes_amount):
        # To simplify we'll assume this is hooked up
        # to a single filename.
        with self._lock:
            self._seen_so_far += bytes_amount
            sys.stdout.write(
                "\r%s --> %s bytes transferred" % (
                    self._filename, self._seen_so_far))
            sys.stdout.flush()

b = 'ripkort'
f = 'Samsara-1.3.5.RELEASE.jar'
s3 = boto3.resource('s3')

try:
    s3.Bucket(b).download_file(f, f,Callback=ProgressPercentage(f))
except botocore.exceptions.ClientError as e:
    if e.response['Error']['Code'] == "404":
        print("The object doesn't exist.")
    else:
        raise
