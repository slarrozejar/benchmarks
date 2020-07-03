#! /usr/bin/python3
import pygraphviz as pgv
import sys
import os

def test_nochange():
    os.system('./dotStyle.py graph.dot > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("graph.dot")
    if(test == result):
        print("\033[32m" + "Test no change: Passed")
    else:
        print("\033[31m" + "Test no change: Failed")

def test_line_node():
    os.system('(./dotStyle.py graph.dot -sn "b=3&&a=4" color=yellow) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_node.dot")
    if(test == result):
        print("\033[32m" + "Test line node: Passed")
    else:
        print("\033[31m" + "Test line node: Failed")

test_nochange()
test_line_node()
