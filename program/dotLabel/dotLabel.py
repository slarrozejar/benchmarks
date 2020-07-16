#!/usr/bin/env python3
import argparse
import string
import pygraphviz as pgv
import sys

def get_pieces(str):
    """ Takes a string with format a=b where a and b are two substrings and a
    doesn't contain '=' and returns substrings a and b. """
    argts = str.partition("=")
    a = argts[0]
    b = argts[2]
    return a, b


def parse_format(str):
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

def get_infos(coll):
    """ From the collection coll, extracts informations necessary to modify a
    graph: the attributes to replace are gathered in the list attributes_to_replace,
    the formatted strings are stored in format_strings and the attributes
    whose values will be added in the formatted strings are stored in the list
    attributes. """
    attributes_to_replace = []
    format_strings = []
    attributes = []
    for elmt in coll:
        attribute_to_replace, replace_string = get_pieces(elmt[0])
        format_string, attributes_names = parse_format(replace_string)
        attributes_to_replace.append(attribute_to_replace)
        format_strings.append(format_string)
        attributes.append(attributes_names)
    return attributes_to_replace, format_strings, attributes

def apply_changes(obj, attributes_to_replace, format_strings, attributes):
    """ From a collection of objects obj which is either the nodes or the edges
    of a pygraphviz graph, apply changes specified in attributes_to_replace,
    format_strings, attributes. """
    for elmt in obj:
        m = []
        unknown_attributes = ""
        for i in range(len(attributes_to_replace)):
            string, unknown_attributes = instantiate_format(elmt, format_strings[i], attributes[i], unknown_attributes)
            m.append((attributes_to_replace[i], string))
        for attr,msg in m:
            elmt.attr[attr] = msg
        if(len(unknown_attributes) > 0):
            sys.stderr.write("Warning: node " + str(elmt) + " has no attribute(s): " + unknown_attributes + "\n")

# Create parser
parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="graph (with dot format) to change")
parser.add_argument("-n", "--nodes", type=str, nargs=1, action='append',
                    help="""-n attribute=value, attribute is the name of an attribute already in use in graph or a
    new attribute and value is a string which can contain the value of other
    attributes when specified between percent signs. Sets attribute to value.""")
parser.add_argument("-e", "--edges", type=str, nargs=1, action='append',
                    help="""-e attribute=value, attribute is the name of an attribute already in use in graph or a
    new attribute and value is a string which can contain the value of other
    attributes when specified between percent signs. Sets attribute to value.""")
args = parser.parse_args()

# Create graph
if(args.graph[0] == "-"):
    G=pgv.AGraph(sys.stdin.read())
else:
    G=pgv.AGraph(args.graph[0])

# Apply changes on nodes
if(args.nodes):
    # Extract necessary pieces of information
    attributes_to_replace, format_strings, attributes = get_infos(args.nodes)
    # Apply changes on the graph
    apply_changes(G.nodes(), attributes_to_replace, format_strings, attributes)

# Apply changes on edges
if(args.edges):
    # Extract necessary pieces of information
    attributes_to_replace, format_strings, attributes = get_infos(args.edges)
    # Apply changes on the graph
    apply_changes(G.edges(), attributes_to_replace, format_strings, attributes)

G.write(sys.stdout)
