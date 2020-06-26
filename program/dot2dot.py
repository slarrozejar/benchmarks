#! /usr/bin/python3

import argparse
import string
import pygraphviz as pgv
import sys
import warnings

def get_pieces(str):
    argts = str.partition("=")
    attribute_to_replace = argts[0]
    replace_string = argts[2]
    return attribute_to_replace, replace_string


def parse_format(str):
    initial = str
    lb = [] # lower bounds of attributes to consider
    up = [] # upper bouds of attributes to consider
    i = 0

    # Get lower and upper bounds
    while(str!="" and str.find("%")!=-1):
        tmp = str.find("%")
        lb.append(i+tmp)
        i += tmp + 1
        str=str[tmp+1:]
        tmp = str.find("%")
        up.append(i+tmp)
        i += tmp + 1
        str=str[tmp+1:]

    attributes_values = [] # Names of attributes' values to consider
    for i in range(len(lb)):
        attributes_values.append(initial[lb[i]+1:up[i]])

    # Create format string
    if(len(lb)>0):
        format_string = initial[0:lb[0]] + "%s"
    else:
        format_string = initial
    for i in range(len(lb)-1):
        format_string += initial[up[i]+1:lb[i+1]] + "%s"
    return format_string, attributes_values

def instiate_format(elmt, format_string, attributes_values):
    return format_string % tuple([n.attr[a] if (n.attr[a] != None) else "" for a in attributes_values])

parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="graph to change")
parser.add_argument("-n", "--nodes", type=str, nargs=1, action='append',
                    help="apply changes on nodes")
parser.add_argument("-e", "--edges", type=str, nargs=1, action='append',
                    help="apply changes on edges")
args = parser.parse_args()

if(args.graph[0] == "-"):
    G=pgv.AGraph(sys.stdin.read())
else:
    G=pgv.AGraph(args.graph[0])
if(args.nodes):
    attributes_to_replace = []
    format_strings = []
    attributes = []
    for node in args.nodes:
        attribute_to_replace, replace_string = get_pieces(node[0])
        format_string, attributes_values = parse_format(replace_string)
        attributes_to_replace.append(attribute_to_replace)
        format_strings.append(format_string)
        attributes.append(attributes_values)
    for n in G.nodes():
        m = []
        unknown_attributes = ""
        Nodes = args.nodes
        for i in range(len(Nodes)):
            node = Nodes[i][0]
            m.append((attributes_to_replace[i], instiate_format(n, format_strings[i], attributes[i])))
            for a in attributes[i]:
                if(n.attr[a] == None):
                    if(not (a in unknown_attributes)):
                        unknown_attributes += a
        for atr,msg in m:
            n.attr[atr] = msg
        if(len(unknown_attributes) > 0):
            sys.stderr.write("Warning: node " + str(n) + " has no attribute(s): " + unknown_attributes + "\n")

if(args.edges):
    attributes_to_replace = []
    format_strings = []
    attributes = []
    for edge in args.edges:
        attribute_to_replace, replace_string = get_pieces(edge[0])
        format_string, attributes_values = parse_format(replace_string)
        attributes_to_replace.append(attribute_to_replace)
        format_strings.append(format_string)
        attributes.append(attributes_values)
    for e in G.edges():
        m = []
        unknown_attributes = ""
        Edges = args.edges
    for i in range(len(Edges)):
        node = Edges[i][0]
        m.append((attributes_to_replace[i], instiate_format(e, format_strings[i], attributes[i])))
        for a in attributes[i]:
            if(e.attr[a] == None):
                if(not (a in unknown_attributes)):
                    unknown_attributes += a
        for atr,msg in m:
            e.attr[atr]=msg
        if(len(unknown_attributes) > 0):
            sys.stderr.write("Warning: edge " + str(e) + " has no attribute(s): " + unknown_attributes + "\n")

G.write(sys.stdout)
