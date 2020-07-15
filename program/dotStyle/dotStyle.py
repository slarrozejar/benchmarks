#!/usr/bin/env python3
import argparse
import pygraphviz as pgv
import sys
import re
import json
import os
from collections import namedtuple

Change = namedtuple('Change', ['cond', 'attr'])

def get_infos(dct):
    """ From a dictionnary dct containing attributes with their values, extracts
    a list of pairs (attr, val). The elements contained in dct must be strings.
    """
    res = []
    for elmt in dct:
        res.append((elmt, dct[elmt]))
    return res

def get_infos_RE(dct):
    """ From a dictionnary dct containing attributes with their values, extracts
    a list of pairs (attr, val). The elements contained in dct must be strings.
    The values 'val' are stored as regular expressions. """
    res = []
    for elmt in dct:
        replace_string = re.compile(dct[elmt])
        if((elmt == "") or (replace_string == "")):
            print("Condition with empty arguments")
            exit()
        res.append((elmt, replace_string))
    return res

def parse_atrr(str):
    """ Takes a string with format a=b where a and b are two substrings and a doesn't
    contain '=' and return the substrings a and b. """
    str = str.replace("'","") # delete '' so that it won't interfere during matching phase
    argts = str.partition("=")
    attribute_to_replace = argts[0]
    replace_string = argts[2]
    if((attribute_to_replace=="") or (replace_string=="")):
        print("Condition with empty arguments")
        exit()
    return attribute_to_replace, replace_string

def parse_split(str):
    """ Takes a string possibly containing substrings separated by '&&'.
    Splits the string str according to '&&'. Ignores '&&' if contained inside ''.
    Ends the program if there are spaces outside ''. Returns the list of
    subtrings separated by '&&'. """
    ignore = False # inside '' or not
    i = 0
    lb = 0 # lower bound of the next substring to extract
    n = len(str)
    res = []
    while(i < n):
        tmp = str[i]
        # Update boolean ignore
        if(tmp == "'"):
            ignore = not ignore
            i += 1
        # Append substring to res if necessary
        elif((tmp == '&') and (i < n-1) and (str[i+1] == '&')):
            if(not ignore):
                res.append(str[lb:i])
                lb = i+2
            i += 2
        # Check wether program should end
        elif((tmp == ' ') and (not ignore)):
            print("Spaces outside argument value")
            exit()
        else:
            i += 1
    # Append last subtring to res
    if(not ignore):
        res.append(str[lb:n])
    return res

def parse_format(str):
    """ Takes a string possibly containing substrings separated by '&&'. The substrings
    have format "attr=val" and can contain '&&' if inside ''. Returns a list of
    pairs (attr, val). """
    substr_list = parse_split(str)
    res = []
    for s in substr_list:
        attr, val = parse_atrr(s)
        val=re.compile(val+'$')
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
            attribute_to_replace, value = parse_atrr(elmt[i])
            style.append((attribute_to_replace, value))
        c = Change(cond,style)
        changes.append(c)
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
        cond = get_infos_RE(dct[elmt]["condition"])
        style = get_infos(dct[elmt]["dotStyle"])
        if(dct[elmt]["object"] == "node"):
            c = Change(cond,style)
            node_changes.append(c)
        else:
            c = Change(cond,style)
            edge_changes.append(c)
    return node_changes, edge_changes

def verify_cond(elmt, cond_list):
    """ From the list cond_list, composed of pairs (attr, val), verifies if each
    attribute named attr of elmt has value val. Returns true if all conditions
     were verified and false otherwise. """
    res = True
    if(cond_list == None):
        return True
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
    is a list of named tuples (cond, style) containing a style to apply when the conditions
    in cond are verified. Applies the necessary changes on the graph. """
    for elmt in coll:
        to_change = []
        # Store the attributes to replace and the value to give them
        for change in changes:
            cond = change[0]
            style = change[1]
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

G.write(sys.stdout)
