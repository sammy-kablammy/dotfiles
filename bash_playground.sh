#!/bin/bash

# some bash examples. likely going to be bash-only, no POSIX shell here

# Parameter Expansion examples
TESTSTR="Hello World"
echo ${TESTSTR,,} # hello world
echo ${TESTSTR^^} # HELLO WORLD

# ARRAYS:
# 0-based non-negative-integer-indexed arrays
declare -a indexed
indexed[0]='zero'
indexed[4]='four' # you can skip, skipped entries become ''
echo ${indexed[0]} # 'zero'
echo ${indexed[1]} # ''
echo ${indexed[*]} # 'zero four'
# (only string keys?) associative arrays
declare -A associative
associative['foo']='hello'
associative['bar']='hi'
echo ${associative[*]} # 'hello hi'

# Unquoted, [*] and [@] are the same. Quoted, [*] expands to a single word with
# the array's elements separated by spaces (technically it's based on IFS), and
# [@] expands each element as a separate word

declare -a arr=(one two 'three four' five)
echo ${arr[0]} # 'one'
echo ${arr[2]} # 'three four'

echo ''
for thing in ${arr[*]}; do echo $thing; done
# one
# two
# three
# four
# five

echo ''
for thing in ${arr[@]}; do echo $thing; done
# one
# two
# three
# four
# five

echo ''
for thing in "${arr[*]}"; do echo $thing; done
# one two three four five

echo ''
for thing in "${arr[@]}"; do echo $thing; done
# one
# two
# three four
# five
