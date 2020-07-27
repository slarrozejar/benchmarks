#! /usr/bin/python3
import pygraphviz as pgv
import sys
import os

def test_node_label():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "" label="%color%") > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_node.dot")
    if(test == result):
        print("\033[32m" + "Test node label: Passed")
    else:
        print("\033[31m" +"Test node label: Failed")

def test_edge_label():
    os.system('(./../dotStyle/dotStyle.py graph.dot -e "" label="%color%") > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_edge.dot")
    if(test == result):
        print("\033[32m" + "Test edge label: Passed")
    else:
        print("\033[31m" + "Test edge label: Failed")

def test_format_string():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "" label="%color%(%b%), %b%%s%" -e "" label="%color%(%b%), %b%%s%") > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_format_string.dot")
    if(test == result):
        print("\033[32m" + "Test format string: Passed")
    else:
        print("\033[31m" + "Test format string: Failed")

def test_inversion():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "" a="%b%" -n "" b="%a%" -e "" a="%b%" -e "" b="%a%") > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_inversion.dot")
    if(test == result):
        print("\033[32m" + "Test inversion: Passed")
    else:
        print("\033[31m" + "Test inversion: Failed")

def test_multiple_nodes_label():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "" a=dog -n "" b=cat) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_multiple_nodes.dot")
    if(test == result):
        print("\033[32m" + "Test test multiple nodes label: Passed")
    else:
        print("\033[31m" + "Test test multiple nodes label: Failed")

def test_multiple_edges_label():
    os.system('(./../dotStyle/dotStyle.py graph.dot -e "" a=dog -e "" b=cat) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_multiple_edges.dot")
    if(test == result):
        print("\033[32m" + "Test test multiple edges label: Passed")
    else:
        print("\033[31m" + "Test test multiple edges label: Failed")

def test_nochange():
    os.system('./../dotStyle/dotStyle.py graph.dot > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("graph.dot")
    if(test == result):
        print("\033[32m" + "Test no change: Passed")
    else:
        print("\033[31m" + "Test no change: Failed")

def test_line_node():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "b=3&&a=4" color=yellow) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_node.dot")
    if(test == result):
        print("\033[32m" + "Test line node: Passed")
    else:
        print("\033[31m" + "Test line node: Failed")

def test_line_edge():
    os.system('(./../dotStyle/dotStyle.py graph.dot -e "b=1" color=yellow) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_edge.dot")
    if(test == result):
        print("\033[32m" + "Test line edge: Passed")
    else:
        print("\033[31m" + "Test line edge: Failed")

def test_line_graph():
    os.system('(./../dotStyle/dotStyle.py graph.dot -g label="Name of the graph" font="Helvetica") > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_graph.dot")
    if(test == result):
        print("\033[32m" + "Test line graph: Passed")
    else:
        print("\033[31m" + "Test line graph: Failed")

def test_line_multiple_nodes():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "b=3&&a=4" color=yellow -n label=n3 color=blue) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_line_multiple_nodes.dot")
    if(test == result):
        print("\033[32m" + "Test line multiple nodes: Passed")
    else:
        print("\033[31m" + "Test line multiple nodes: Failed")

def test_file():
    os.system('(./../dotStyle/dotStyle.py graph.dot -s test.json) > test.dot 2>/dev/null')
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_file.dot")
    if(test == result):
        print("\033[32m" + "Test file: Passed")
    else:
        print("\033[31m" + "Test file: Failed")

def test_node_bad_condition():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "=blabla" color=blue) > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Condition with empty arguments\n"):
        print("\033[32m" + "Test node bad condition: Passed")
    else:
        print("\033[31m" + "Test node bad condition: Failed")

def test_edge_bad_condition():
    os.system('(./../dotStyle/dotStyle.py graph.dot -e "=blabla" color=blue) > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Condition with empty arguments\n"):
        print("\033[32m" + "Test edge bad condition: Passed")
    else:
        print("\033[31m" + "Test edge bad condition: Failed")

def test_file_bad_condition():
    os.system('(./../dotStyle/dotStyle.py graph.dot -s test_bad_condition.json) > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Condition with empty arguments\n"):
        print("\033[32m" + "Test file bad condition: Passed")
    else:
        print("\033[31m" + "Test file bad condition: Failed")

def test_and():
    os.system("""(./../dotStyle/dotStyle.py graph.dot -n "label='n3&&n2'&&a=toto" color=aquamarine) > test.dot 2>/dev/null""")
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_and.dot")
    if(test == result):
        print("\033[32m" + "Test and: Passed")
    else:
        print("\033[31m" + "Test and: Failed")

def test_bad_spaces():
    os.system('(./../dotStyle/dotStyle.py graph.dot -n "a=le vent e lève&&b=3") > test 2>/dev/null')
    res = open("test","r")
    content = res.read()
    if(content == "Spaces outside argument value\n"):
        print("\033[32m" + "Test bad spaces: Passed")
    else:
        print("\033[31m" + "Test bad spaces: Failed")

def test_no_condition_line():
    os.system("""(./../dotStyle/dotStyle.py graph.dot -n "" color=red -e "" color=blue) > test.dot 2>/dev/null""")
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_no_condition.dot")
    if(test == result):
        print("\033[32m" + "Test no condition line: Passed")
    else:
        print("\033[31m" + "Test no condition line: Failed")

def test_no_condition_file():
    os.system("""(./../dotStyle/dotStyle.py graph.dot -s test_no_condition.json) > test.dot 2>/dev/null""")
    test = pgv.AGraph("test.dot")
    result = pgv.AGraph("test_no_condition.dot")
    if(test == result):
        print("\033[32m" + "Test no condition file: Passed")
    else:
        print("\033[31m" + "Test no condition file: Failed")

test_node_label()
test_edge_label()
test_format_string()
test_inversion()
test_multiple_nodes_label()
test_multiple_edges_label()
test_nochange()
test_line_node()
test_line_edge()
test_line_graph()
test_line_multiple_nodes()
test_file()
test_node_bad_condition()
test_edge_bad_condition()
test_file_bad_condition()
test_and()
test_bad_spaces()
test_no_condition_line()
test_no_condition_file()
