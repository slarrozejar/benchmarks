dot2dot
=======

Description
-----------

This tool allows to change some attributes' value in order to highlight some pieces of information in 
a graph with dot format. The attributes can be added/changed either on nodes or on edges. **dot2dot** is
written in Python and requires Python 3 to be executed. 

Usage
-----
To execute this tool, simply launch the line tool:

    ./dot2dot.py [graph] [options]
    where:
        graph must be a graphviz graph with dot format
        options are:
        -n attribute=value
        -e attribute=value 
        where attribute is the name of an attribute already in use in graph or a 
        new attribute and value is a string which can contain the value of other
        attributes when specified between %. 
        
For example, `./dot2dot graph.dot -n label="a: %a%,b: %b%"` will return a graph with dot format whose 
nodes are labelled *"a: %a%,b: %b%"* where *%a%* and *%b%* are replaced by the values of their attributes 
*a* and *b*. If a node doesn't possess an attribute *a* or *b*, the value will be replaced by "".
The usage is the same for applying changes on edges. 

The options can be used more than once in a line tool and the values considered will be the values of the 
original graph given as parameter.
