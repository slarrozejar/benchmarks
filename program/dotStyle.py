#! /usr/bin/python3
import argparse
import pygraphviz as pgv
import sys
import re
import json

def get_infos(dct, cond):
    """ From a dictionnary dct containing attributes with their values, extracts
    a list of pairs (attr, val). The elements contained in dct must be strings.
    If cond is 'True', the values 'val' are stored as regular expressions and as
    strings otherwise. """
    res = []
    for elmt in dct:
        if cond:
            res.append((elmt, re.compile(dct[elmt])))
        else:
            res.append((elmt, dct[elmt]))
    return res

def get_pieces(str):
    """ Takes a string with format a=b where a and b are two substrings and a doesn't
    contain '=' and return substrings a and b. """
    argts = str.partition("=")
    attribute_to_replace = argts[0]
    replace_string = argts[2]
    return attribute_to_replace, replace_string


def parse_format(str):
    """ Takes a string possibly containing substrings separated by '&&'. The substrings
    have format "attr=val" and don't contain "&&". Returns a list of pairs (attr, val). """
    print(str)
    substr_list = str.split("&&")
    print(substr_list)
    res = []
    for s in substr_list:
        attr, val = get_pieces(s)
        val=re.compile(val)
        res.append((attr, val))
    print(res)
    return res

def verify_cond(elmt, cond_list):
    """ From a list of pairs (attr, val), verifies if each attribute named attr
    of elmt has value val. Returns true if all conditions were verified and false
    otherwise. """
    res = True
    if(cond_list == None):
        return False
    for (attr, val) in cond_list:
        if((elmt.attr[attr] == None) or (val.match(elmt.attr[attr]) == None)):
            res = False
    return res

def apply_changes(elmt, to_change):
    """ to_change is a list of pairs (attr, val). This function sets the attributes
    attr of elmt to the corresponding value val. """
    for (attr, val) in to_change:
        elmt.attr[attr] = val


# Create parser
parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="Graph to change")
parser.add_argument("-s", "--style", type=str, nargs=1,
                    help=""" Applies changes specified in a json file given as
                    parameter. """)
parser.add_argument("-sn", "--style_nodes", nargs='+', type=str, action='append',
                    help=""" If the condition(s) given by the first argument is/are verified,
                     applies changes specified by the following arguments on nodes. """)
parser.add_argument("-se", "--style_edges", type=str, nargs='+', action='append',
                    help=""" If condition(s) given by the first argument is/are verified,
                     applies changes specified by the following arguments on edges. """)
args = parser.parse_args()

# Create graph
if(args.graph[0] == "-"):
    G=pgv.AGraph(sys.stdin.read())
else:
    G=pgv.AGraph(args.graph[0])

# Apply changes on nodes
if(args.style_nodes):
    cond = []
    changes = []
    # Create the list of conditions to verify
    for node in args.style_nodes:
        cond.append(parse_format(node[0]))
    # Extract the attributes to change and the values to give them
    for i in range(len(args.style_nodes)):
        changes.append([])
        for j in range(1, len(args.style_nodes[i])):
            attribute_to_replace, value = get_pieces(args.style_nodes[i][j])
            changes[i].append((attribute_to_replace, value))
    for n in G.nodes():
        to_change = []
        for i in range(len(args.style_nodes)):
            if(verify_cond(n, cond[i])):
                # Store the attributes to change and the value to give them
                to_change = to_change + changes[i]
        # Set new values to attributes
        apply_changes(n, to_change)

# Apply changes on edges
if(args.style_edges):
    cond = []
    changes = []
    # Create the list of conditions to verify
    for edge in args.style_edges:
        cond.append(parse_format(edge[0]))
    # Extract the attributes to change and the values to give them
    for i in range(len(args.style_edges)):
        changes.append([])
        for j in range(1, len(args.style_edges[i])):
            attribute_to_replace, value = get_pieces(args.style_edges[i][j])
            changes[i].append((attribute_to_replace, value))
    for e in G.edges():
        to_change = []
        for i in range(len(args.style_edges)):
            if(verify_cond(e, cond[i])):
                # Store the attributes to change and the value to give them
                to_change = to_change + changes[i]
        # Set new values to attributes
        apply_changes(e, to_change)

# Apply changes with json file
if(args.style):
    # Exctract datas from json file
    with open(args.style[0]) as json_data:
        dct = json.load(json_data)
    node_changes = []
    edge_changes = []
    # Build a list of changes to apply on nodes and a list of changes to apply on edges
    for elmt in dct:
        cond = get_infos(dct[elmt]["condition"], True)
        style = get_infos(dct[elmt]["dotStyle"], False)
        if(dct[elmt]["object"] == "node"):
            node_changes.append((cond, style))
        else:
            edge_changes.append((cond, style))

    # Apply necessary changes on nodes
    for n in G.nodes():
        to_change = []
        # Store the attributes to replace and the value to give them
        for cond, style in node_changes:
            if(verify_cond(n, cond)):
                to_change = to_change + style
        # Set new values to attributes
        apply_changes(n, to_change)

    # Apply necessary changes on edges
    for e in G.edges():
        to_change = []
        # Store the attributes to replace and the value to give them
        for cond, style in edge_changes:
            if(verify_cond(e, cond)):
                to_change = to_change + style
        # Set new values to attributes
        apply_changes(e, to_change)


G.write(sys.stdout)
