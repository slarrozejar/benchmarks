#! /usr/bin/python3
import argparse
import pygraphviz as pgv
import sys
import re

def get_pieces(str):
    """ Takes a string with format a=b where a and b are two substrings and a doesn't
    contain '=' and return substrings a and b. """
    argts = str.partition("=")
    attribute_to_replace = argts[0]
    replace_string = argts[2]
    return attribute_to_replace, replace_string


def parse_format(str):
    """ Takes a string possibly containing substrings separated by '&&'. The substrings
    have format "attr=val". Return a list of pairs (attr, val). """
    substr_list = str.split("&&")
    res = []
    for s in substr_list:
        attr, val = get_pieces(s)
        val=re.compile(val)
        res.append((attr, val))
    return res

def verify_cond(elmt, cond_list):
    """ From a list of pairs (attr, val), verifies if each attribute named attr
    of elmt has value val. Returns true if all consitions were verified and false
    otherwise. """
    res = True
    for (attr, val) in cond_list:

        if((elmt.attr[attr] != None) and (val.match(elmt.attr[attr]) == None)):
            res = False
    return res

def apply_changes(elmt, to_change):
    """ to_change is a list of pairs (attr, val). This function sets the attributes
    attr of elmt to the corresponding value val. """
    for (attr, val) in to_change:
        elmt.attr[attr] = val


# Create parser
parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="graph to change")
parser.add_argument("-sn", "--style_nodes", nargs='+', type=str, action='append',
                    help="if condition given by the first argument is verified, aplies changes specified by the second argument on nodes")
parser.add_argument("-se", "--style_edges", type=str, nargs='+', action='append',
                    help="if condition given by the first argument is verified, aplies changes specified by the second argument on edges")
args = parser.parse_args()

# Create graph
if(args.graph[0] == "-"):
    G=pgv.AGraph(sys.stdin.read())
else:
    G=pgv.AGraph(args.graph[0])

# Apply changes on nodes
if(args.style_nodes):
    cond = []
    # Create the list of conditions to verify
    for node in args.style_nodes:
        cond.append(parse_format(node[0]))
    for n in G.nodes():
        to_change = []
        for i in range(len(args.style_nodes)):
            if(verify_cond(n, cond[i])):
                # Extract the attributes to change and the value to give them
                for j in range(1, len(args.style_nodes[i])):
                    attribute_to_replace, value = get_pieces(args.style_nodes[i][j])
                    to_change.append((attribute_to_replace, value))
        # Set new values to attributes
        apply_changes(n, to_change)

# Apply changes on edges
if(args.style_edges):
    cond = []
    # Create the list of conditions to verify
    for edge in args.style_edges:
        cond.append(parse_format(edge[0]))
    for e in G.edges():
        to_change = []
        for i in range(len(args.style_edges)):
            if(verify_cond(e, cond[i])):
                # Extract the attributes to change and the value to give them
                for j in range(1, len(args.style_edges[i])):
                    attribute_to_replace, value = get_pieces(args.style_edges[i][j])
                    to_change.append((attribute_to_replace, value))
        # Set new values to attributes
        apply_changes(e, to_change)

G.write(sys.stdout)
