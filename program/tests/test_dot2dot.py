#! /usr/bin/python3
import pygraphviz as pgv
import sys
import os

def test_nochange():
    os.system('./../dot2dot.py graph.dot > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("graph.dot")
    if(test == result):
        print("\033[32m" + "Test no change: Passed")
    else:
        print("\033[31m" + "Test no change: Failed")

def test_node():
    os.system('./../dot2dot.py -n label="%color%" graph.dot > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_node.dot")
    if(test == result):
        print("\033[32m" + "Test node: Passed")
    else:
        print("\033[31m" +"Test node: Failed")

def test_edge():
    os.system('./../dot2dot.py -e label="%color%" graph.dot > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_edge.dot")
    if(test == result):
        print("\033[32m" + "Test edge: Passed")
    else:
        print("\033[31m" + "Test edge: Failed")

def test_nofile_node():
    os.system('cat graph.dot | ./../dot2dot.py -n label="%color%" "-" > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_node.dot")
    if(test == result):
        print("\033[32m" + "Test node no file: Passed")
    else:
        print("\033[31m" + "Test node  no file: Failed")

def test_nofile_edge():
    os.system('cat graph.dot | ./../dot2dot.py -e label="%color%" "-" > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_edge.dot")
    if(test == result):
        print("\033[32m" + "Test edge no file: Passed")
    else:
        print("\033[31m" + "Test edge no file: Failed")

def test_format_string():
    os.system('./../dot2dot.py graph.dot -n label="%color%(%b%), %b%%s%" -e label="%color%(%b%), %b%%s%" > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_format_string.dot")
    if(test == result):
        print("\033[32m" + "Test format string: Passed")
    else:
        print("\033[31m" + "Test format string: Failed")

def test_inversion():
    os.system('./../dot2dot.py graph.dot -n a="%b%" -n b="%a%" -e a="%b%" -e b="%a%" > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_inversion.dot")
    if(test == result):
        print("\033[32m" + "Test inversion: Passed")
    else:
        print("\033[31m" + "Test inversion: Failed")

def test_multiple_nodes():
    os.system('./../dot2dot.py graph.dot -n a=dog -n b=cat > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_multiple_nodes.dot")
    if(test == result):
        print("\033[32m" + "Test test multiple nodes: Passed")
    else:
        print("\033[31m" + "Test test multiple nodes: Failed")

def test_multiple_edges():
    os.system('./../dot2dot.py graph.dot -e a=dog -e b=cat > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_multiple_edges.dot")
    if(test == result):
        print("\033[32m" + "Test test multiple edges: Passed")
    else:
        print("\033[31m" + "Test test multiple edges: Failed")

test_nochange()
test_node()
test_edge()
test_nofile_node()
test_nofile_edge()
test_format_string()
test_multiple_nodes()
test_multiple_edges()
test_inversion()
