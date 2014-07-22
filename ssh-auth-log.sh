#!/usr/bin/env bash

if [ -f "/var/log/auth.log" ]; then
    cat /var/log/auth.log | grep "sshd.*Accepted"
elif [ -f "/var/log/secure" ]; then
    cat /var/log/secure   | grep "sshd.*Accepted"
fi

