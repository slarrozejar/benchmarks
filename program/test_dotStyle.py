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

def test_line_edge():
    os.system('(./dotStyle.py graph.dot -se "b=1" color=yellow) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_edge.dot")
    if(test == result):
        print("\033[32m" + "Test line edge: Passed")
    else:
        print("\033[31m" + "Test line edge: Failed")

def test_line_multiple_nodes():
    os.system('(./dotStyle.py graph.dot -sn "b=3&&a=4" color=yellow -sn label=n3 color=blue) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_multiple_nodes.dot")
    if(test == result):
        print("\033[32m" + "Test line multiple nodes: Passed")
    else:
        print("\033[31m" + "Test line multiple nodes: Failed")

def test_file():
    os.system('(./dotStyle.py graph.dot -s test.json) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_file.dot")
    if(test == result):
        print("\033[32m" + "Test file: Passed")
    else:
        print("\033[31m" + "Test file: Failed")

def test_node_bad_condition():
    os.system('(./dotStyle.py graph.dot -sn "=blabla" color=blue) > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Condition with empty arguments\n"):
        print("\033[32m" + "Test node bad condition: Passed")
    else:
        print("\033[31m" + "Test node bad condition: Failed")

def test_edge_bad_condition():
    os.system('(./dotStyle.py graph.dot -se "=blabla" color=blue) > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Condition with empty arguments\n"):
        print("\033[32m" + "Test edge bad condition: Passed")
    else:
        print("\033[31m" + "Test edge bad condition: Failed")

def test_file_bad_condition():
    os.system('(./dotStyle.py graph.dot -s test_bad_condition.json) > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Condition with empty arguments\n"):
        print("\033[32m" + "Test file bad condition: Passed")
    else:
        print("\033[31m" + "Test file bad condition: Failed")

def test_and():
    os.system("""(./dotStyle.py graph.dot -sn "label='n3&&n2'&&a=toto" color=aquamarine) > test.dot 2>/dev/null""")
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_and.dot")
    if(test == result):
        print("\033[32m" + "Test and: Passed")
    else:
        print("\033[31m" + "Test and: Failed")

def test_bad_spaces():
    os.system('(./dotStyle.py graph.dot -sn "a=le vent se lève&&b=3") > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Spaces outside argument value\n"):
        print("\033[32m" + "Test bad spaces: Passed")
    else:
        print("\033[31m" + "Test bad spaces: Failed")

test_nochange()
test_line_node()
test_line_edge()
test_line_multiple_nodes()
test_file()
test_node_bad_condition()
test_edge_bad_condition()
test_file_bad_condition()
test_and()
test_bad_spaces()
