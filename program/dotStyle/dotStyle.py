#!/usr/bin/env python3
import argparse
import pygraphviz as pgv
import sys
import re
import json
import os
from collections import namedtuple

Change = namedtuple('Change', ['cond', 'attr', 'attr_names'])

def get_infos(dct):
    """ From a dictionnary dct containing attributes with their values, where the
    values possibly contain some %str% where str is a string without
    spaces and without '%' and creates a formatted string where all %str% are
    replaced by '%s'. The substrings inbetween %str% don't contain '%' either.
    Returns a list of pairs (attr, val) where val is the formatted string and a
    list of all words which were between '%'. The elements contained in dct must
    be strings. """
    res = []
    attributes = []
    for elmt in dct:
        format_string, attributes_names = parse_format_string(dct[elmt])
        res.append((elmt, format_string))
        attributes.append(attributes_names)
    return res, attributes

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
    if(str==""):
        return "",""
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

def parse_format_string(str):
    """ Takes a string possibly containing some %str% where str is a string without
    spaces and without '%' and creates a formatted string where all %str% are
    replaced by '%s'. The substrings inbetween %str% don't contain '%' either.
    Returns the formatted string and a list of all words which were between '%'. """
    initial = str
    attributes_indices = [] # list of pairs (lb, ub) lower and upper bounds to consider
    i = 0

    # Get lower and upper bounds
    f=str.find("%")
    while((str != "") and (f != -1)):
        tmp = f
        lb = i+tmp
        i += tmp + 1
        str=str[tmp+1:]
        tmp = str.find("%")
        ub = i+tmp
        i += tmp + 1
        str=str[tmp+1:]
        attributes_indices.append((lb, ub))
        f=str.find("%")

    attributes = [] # Names of attributes' values to consider
    for lb, ub in attributes_indices:
        attributes.append(initial[lb+1:ub])

    # No attributes to change
    if(len(attributes_indices)==0):
        return initial, attributes

    # Create format string
    format_string = initial[0:attributes_indices[0][0]] + "%s"
    for i in range(len(attributes_indices)-1):
        format_string += initial[attributes_indices[i][1]+1:attributes_indices[i+1][0]] + "%s"
    return format_string, attributes

def graph_extract_changes(obj):
    """ obj is a list of lists where each element of the lists is a string like
    'attr=val' where attr doesn't contain '='. Returns a list of pairs (attr, value). """
    changes = []
    for elmt in obj:
        attribute_to_replace, value = parse_atrr(elmt)
        changes.append((attribute_to_replace, value))
    return changes

def extract_changes(obj):
    """ obj is a list of lists where each element of the lists except from the
    first one is a string like 'attr=val' where attr doesn't contain '='. The first
    elements are strings with format 'cond1&&cond2&&...&&condN', where condi has
    format attr=value and attr doesn't contain '='. Returns a list of pairs (cond, style, attr_names)
    where cond and style are lists containing the corresponding pairs (attr, value).
    Values contained in style can be formatted strings as in parse_format_string.
    attr_names is a list of attributes' names whose values are needed to update
    other attributes' values. """
    changes = []
    for elmt in obj:
        attributes = []
        style = []
        cond=parse_format(elmt[0])
        for i in range(1, len(elmt)):
            attribute_to_replace, value = parse_atrr(elmt[i])
            format_string, attributes_names = parse_format_string(value)
            style.append((attribute_to_replace, format_string))
            attributes.append(attributes_names)
        c = Change(cond,style,attributes)
        changes.append(c)
    return changes

def dct_to_changes(dct):
    """ From a dictionnary 'dct' where each element contains 'condition', 'dotStyle',
    'object', extract a list of changes to apply on the graph, a list of changes
    to apply to nodes and a list of changes to apply to edges. node_changes and
    edge_changes contain pairs (cond, style, attr_names) where cond and style are lists of
    (attr, value) and graph_changes is a list of pairs (attr, value). Returns the
    lists graph_changes, node_changes and edge_changes which contain the changes
    to apply. attr_names is a list of attributes' names whose values are needed to update
    other attributes' values. """
    node_changes = []
    edge_changes = []
    graph_changes = []
    # Build a list of changes to apply on nodes and a list of changes to apply on edges
    for elmt in dct:
        if(dct[elmt]["object"] == "node"):
            if('condition' in dct[elmt].keys()):
                cond = get_infos_RE(dct[elmt]["condition"])
            else:
                cond = [("",re.compile(""))]
            style, attr_names = get_infos(dct[elmt]["dotStyle"])
            c = Change(cond,style,attr_names)
            node_changes.append(c)
        elif(dct[elmt]["object"] == "edge"):
            if('condition' in dct[elmt].keys()):
                cond = get_infos_RE(dct[elmt]["condition"])
            else:
                cond = [("",re.compile(""))]
            style, attr_names = get_infos(dct[elmt]["dotStyle"])
            c = Change(cond,style,attr_names)
            edge_changes.append(c)
        else:
            style, attr_names = get_infos(dct[elmt]["dotStyle"])
            graph_changes += style
    return graph_changes, node_changes, edge_changes

def verify_cond(elmt, cond_list):
    """ From the list cond_list, composed of pairs (attr, val), verifies if each
    attribute named attr of elmt has value val. Returns true if all conditions
     were verified and false otherwise. """
    res = True
    if(cond_list == None):
        return True
    for attr, val in cond_list:
        if(attr!=""):
            if((elmt.attr[attr] == None) or (val.match(elmt.attr[attr]) == None)):
                res = False
    return res

def instantiate_format(elmt, format_string, attributes, unknown_attributes):
    """ elmt is either a node or an edge of a pygraphviz graph, format_string is a formatted
    string containing (multiple) '%s' to replace, attributes are the names of
    attributes of elmt which will replace the '%s' in the formated string, unknown_attributes
    is a string in which attributes from attributes which do not exist in elmt
    will be added. There must be as much '%s' in format string as elements in
    atttributes_values. Returns the formatted string where '%s' have been replaced by
    the attributes values and the modified string unknown_attributes. """
    args = []
    for a in attributes:
        if((elmt.attr[a] == None) or (elmt.attr[a] == "")):
            args.append("")
            if(not (a in unknown_attributes)):
                unknown_attributes += a
        else:
            args.append(elmt.attr[a])
    return format_string % tuple(args), unknown_attributes

def change_values(elmt, to_change):
    """ to_change is a list of pairs (attr, val). This function sets the attributes
    attr of elmt to the corresponding value val. """
    for (attr, val) in to_change:
        elmt.attr[attr] = val

def apply_changes(coll, changes):
    """ 'coll' is either the nodes or the edges of a pygraphviz graph. 'changes'
    is a list of named tuples (cond, style, attr_names) containing a style to apply when the conditions
    if cond are verified. Applies the necessary changes on the graph. """
    for elmt in coll:
        to_change = []
        unknown_attributes = ""
        # Store the attributes to replace and the value to give them
        for change in changes:
            cond = change[0]
            style = change[1]
            attr_names = change[2]
            if(verify_cond(elmt, cond)):
                for i in range(len(style)):
                    string, unknown_attributes = instantiate_format(elmt, style[i][1], attr_names[i], unknown_attributes)
                    to_change.append((style[i][0], string))
        # Warning message if non existing attribute's values are used
        if(len(unknown_attributes) > 0):
            sys.stderr.write("Warning: node " + str(elmt) + " has no attribute(s): " + unknown_attributes + "\n")

        # Set new values to attributes
        change_values(elmt, to_change)

def graph_apply_changes(G, changes):
    """ 'changes' is a list of pairs (attr, value) specifying containing default
    values which are to add in the graph 'G'. """
    for attr, value in changes:
        G.graph_attr[attr] = value

# Create parser
parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="Graph to change")
parser.add_argument("-s", "--style", type=str, nargs=1,
                    help=""" -s file.json, applies changes specified in a json file given as
                    parameter. """)
parser.add_argument("-g", "--style_graph", nargs='+', type=str, action='append',
                    help=""" -g attr=val attr=val ..., sets the attr to value val. """)
parser.add_argument("-n", "--nodes", nargs='+', type=str, action='append',
                    help=""" -n attr1=val1&&attr2=val2... attr=val attr=val ...,
                    provided all attributes of a node verify attri=vali
                    (where vali can be a regular expression) sets the following
                    attr to value val. """)
parser.add_argument("-e", "--edges", type=str, nargs='+', action='append',
                    help=""" -e attr1=val1&&attr2=val2... attr=val attr=val ...,
                    provided all attributes of an edge verify attri=vali
                    (where vali can be a regular expression) sets the following
                    attr to value val. """)
args = parser.parse_args()

# Create graph
if(args.graph[0] == "-"):
    sys.stderr.write("Reading from standard input\n")
    G=pgv.AGraph(sys.stdin.read())
else:
    G=pgv.AGraph(args.graph[0])

# Apply changes with json file
if(args.style):
    # Create dictionnary from json file
    with open(args.style[0]) as json_data:
        dct = json.load(json_data)
    # Extract changes to apply
    graph_changes, node_changes, edge_changes = dct_to_changes(dct)
    # Apply necessary changes on graph
    graph_apply_changes(G, graph_changes)
    # Apply necessary changes on nodes
    apply_changes(G.nodes(), node_changes)
    # Apply necessary changes on edges
    apply_changes(G.edges(), edge_changes)

# Apply changes on the graph
if(args.style_graph):
    # Create the list of changes to apply
    changes = graph_extract_changes(args.style_graph[0])
    # Apply changes on the graph
    graph_apply_changes(G, changes)

# Apply changes on nodes
if(args.nodes):
    # Create the list of changes to apply depending on conditions
    changes = extract_changes(args.nodes)
    # Apply changes on the graph
    apply_changes(G.nodes(), changes)

# Apply changes on edges
if(args.edges):
    # Create the list of changes to apply depending on conditions
    changes = extract_changes(args.edges)
    # Apply changes on the graph
    apply_changes(G.edges(), changes)

G.write(sys.stdout)
