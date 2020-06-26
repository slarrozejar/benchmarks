import argparse
import string
import pygraphviz as pgv
import sys
import warnings

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
    if(len(lb)>0):
        format_string = initial[0:lb[0]] + "%s"
    else:
        format_string = initial
    for i in range(len(lb)-1):
        format_string += initial[up[i]+1:lb[i+1]] + "%s"
    return format_string, attribute_to_replace, attributes_values

parser = argparse.ArgumentParser()
parser.add_argument("graph", type=str, nargs=1, help="graph to change")
parser.add_argument("-n", "--nodes", type=str, nargs=1, action='append',
                    help="apply changes on nodes")
parser.add_argument("-e", "--edges", type=str, nargs=1, action='append',
                    help="apply changes on edges")
args = parser.parse_args()
G=pgv.AGraph(args.graph[0])

if(args.nodes):
    for n in G.nodes():
        m=[]
        warning=""
        for node in args.nodes:
            node=node[0]
            format_string, attribute_to_replace, attributes_values=string_to_format(node)
            m.append((attribute_to_replace,format_string % tuple([n.attr[a] if (n.attr[a] != None) else "" for a in attributes_values])))
            for a in attributes_values:
                if(n.attr[a]==None):
                    if(not(a in warning)):
                        warning += a
        for atr,msg in m:
            n.attr[atr]=msg
        warnings.warn("node " + n + " has no attribute(s): " + warning)

if(args.edges):
    for e in G.edges():
        m=[]
        warning=""
        for edge in args.edges:
            edge=edge[0]
            format_string, attribute_to_replace, attributes_values=string_to_format(edge)
            m.append((attribute_to_replace,format_string % tuple([e.attr[a] if (e.attr[a] != None) else "" for a in attributes_values])))
            for a in attributes_values:
                if(e.attr[a]==None):
                    if(not(a in warning)):
                        warning += a
        for atr,msg in m:
            e.attr[atr]=msg
        warnings.warn("edge " + e + " has no attribute(s): " + warning)

G.write(sys.stdout)
