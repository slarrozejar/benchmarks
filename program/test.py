#! /usr/bin/python3

import pygraphviz as pgv
import sys
import os

def test_node():
    os.system('./dot2dot.py -n label="%color%" graph.dot > test.dot')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_node.dot")
    if(test == result):
        print("Test node: Passed")
    else:
        print("Test node: Failed")

def test_edge():
    os.system('./dot2dot.py -e label="%color%" graph.dot > test.dot')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_edge.dot")
    if(test == result):
        print("Test edge: Passed")
    else:
        print("Test edge: Failed")

test_node()
test_edge()
