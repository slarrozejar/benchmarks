import argparse
import string
import pygraphviz as pgv
import sys

def string_to_format(n):
    argts = n.partition("=")
    attribute_to_replace = argts[0]
    initial = argts[2]
    n = argts[2]
    lb = [] # lower bounds of attributes to consider
    up = [] # upper bouds of attributes to consider
    i = 0

    # Get lower and upper bounds
    while(n!="" and n.find("%")!=-1):
        tmp = n.find("%")
        lb.append(i+tmp)
        i += tmp + 1
        n=n[tmp+1:]
        tmp = n.find("%")
        up.append(i+tmp)
        i += tmp + 1
        n=n[tmp+1:]

    attributes_values = [] # Names of attributes' values to consider
    for i in range(len(lb)):
        attributes_values.append(initial[lb[i]+1:up[i]])

    # Create format string
    format_string = initial
    for i in range(len(lb)):
        format_string = format_string.replace(initial[lb[i]:up[i]+1], '%s', 1)
    return format_string, attribute_to_replace, attributes_values

def change_nodes(format_string, attribute_to_replace, attributes_values):
    for n in G.nodes():
        n.attr[attribute_to_replace] = format_string % tuple([n.attr[a] if (n.attr[a] != None) else "" for a in attributes_values])

def change_edges(format_string, attribute_to_replace, attributes_values):
    for e in G.edges():
        e.attr[attribute_to_replace] = format_string % tuple([e.attr[a] if (e.attr[a] != None) else "" for a in attributes_values])

parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="graph to change")
parser.add_argument("-n", "--nodes", type=str, nargs=1,
                    help="apply changes on nodes")
parser.add_argument("-e", "--edges", type=str, nargs=1,
                    help="apply changes on edges")
args = parser.parse_args()
G=pgv.AGraph(args.graph[0])
if(args.nodes):
    n=args.nodes[0]
    format_string, attribute_to_replace, attributes_values=string_to_format(n)
    change_nodes(format_string, attribute_to_replace, attributes_values)
if(args.edges):
    e=args.edges[0]
    format_string, attribute_to_replace, attributes_values=string_to_format(e)
    change_edges(format_string, attribute_to_replace, attributes_values)

G.write(sys.stdout)
