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
    substr_list = str.split("&&")
    res = []
    for s in substr_list:
        attr, val = get_pieces(s)
        val=re.compile(val)
        res.append((attr, val))
    return res

def extract_changes(obj):
    """ obj is a list of lists where all elements of the lists except from the
    first one is a string like 'attr=val' where attr doesn't contain '='. The first
    elements are strings with format 'cond1&&cond2&&...&&condN', where condi has
    format attr=value and attr doesn't contain '='. Returns a list of pairs (cond, style)
    where cond and style are lists containing the corresponding pairs (attr, value). """
    changes = []
    for elmt in obj:
        style = []
        cond=parse_format(elmt[0])
        for i in range(1, len(elmt)):
            attribute_to_replace, value = get_pieces(elmt[i])
            style.append((attribute_to_replace, value))
        changes.append((cond, style))
    print(changes)
    return changes

def dct_to_changes(dct):
    """ From a dictionnary 'dct' where each element contains 'condition', 'dotStyle',
    'object', extract a list of list of changes to apply to edges and a list of
    changes to apply to nodes. These lists contain pairs (cond, style) where
    cond and style are lists of (attr, value). Return the lists node_changes and
    edge_changes which contain the changes to apply on the graph. """
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
    return node_changes, edge_changes

def verify_cond(elmt, cond_list):
    """ From a list of pairs (attr, val), verifies if each attribute named attr
    of elmt has value val. Returns true if all conditions were verified and false
    otherwise. """
    res = True
    if(cond_list == None):
        return False
    for attr, val in cond_list:
        if((elmt.attr[attr] == None) or (val.match(elmt.attr[attr]) == None)):
            res = False
    return res

def change_values(elmt, to_change):
    """ to_change is a list of pairs (attr, val). This function sets the attributes
    attr of elmt to the corresponding value val. """
    for (attr, val) in to_change:
        elmt.attr[attr] = val

def apply_changes(coll, changes):
    """ 'coll' is either the nodes or the edges of a pygraphviz graph. 'changes'
    is a list of pairs (cond, style) containing a style to apply when the conditions
    in cond are verified. Applies the necessary changes on the graph. """
    for elmt in coll:
        to_change = []
        # Store the attributes to replace and the value to give them
        for cond, style in changes:
            if(verify_cond(elmt, cond)):
                to_change = to_change + style
        # Set new values to attributes
        change_values(elmt, to_change)

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
    # Create the list of changes to apply depending on conditions
    changes = extract_changes(args.style_nodes)
    # Apply changes on the graph
    apply_changes(G.nodes(), changes)

# Apply changes on edges
if(args.style_edges):
    # Create the list of changes to apply depending on conditions
    changes = extract_changes(args.style_edges)
    # Apply changes on the graph
    apply_changes(G.edges(), changes)

# Apply changes with json file
if(args.style):
    # Create dictionnary from json file
    with open(args.style[0]) as json_data:
        dct = json.load(json_data)
    # Extract changes to apply
    node_changes, edge_changes = dct_to_changes(dct)
    # Apply necessary changes on nodes
    apply_changes(G.nodes(), node_changes)
    # Apply necessary changes on edges
    apply_changes(G.edges(), edge_changes)

G.write(sys.stdout)
