#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/python-lib')
import bitbucket


UNAME = ''
PASS  = ''

CLONE_TYPE_SSH   = 1
CLONE_TYPE_HTTPS = 2




def int_input(msg):
    try:
        return int(raw_input(msg))
    except ValueError:
        return 0

def git_clone(url):
    os.system('git clone --recursive %s' % (url))


def choice_clone_type():
    print 'Select clone type'
    print '1) ssh'
    print '2) https'
    return int_input('>>> ')


def make_repo_url(name, clone_type):
    if CLONE_TYPE_SSH == clone_type:
        return 'git@bitbucket.org:%s/%s.git' % (UNAME, name)
    elif CLONE_TYPE_HTTPS ==clone_type:
        return 'https://%s@bitbucket.org/%s/%s.git' % (UNAME, UNAME, name)
    return ''


def choice_repository():
    print 'Select repositories'
    arr = []
    bb  = bitbucket.BitBucket(UNAME,PASS)
    for repo in bb.user(UNAME).repositories():
        name = repo['name']
        arr.append(name)
        print '%d) %s' % (len(arr), name)

    idx = int_input('>>> ')
    if 0 < idx and idx <= len(arr):
        return arr[idx -1]
    return ''




repo = choice_repository()
if '' != repo:
    type = choice_clone_type()
    if CLONE_TYPE_SSH == type or CLONE_TYPE_HTTPS == type:
        git_clone(make_repo_url(repo, type))


