dot2dot
=======

Description
-----------

This tool allows to change some attributes' value in
a graph with dot format in order to make it easier to read. The attributes can be added/changed either on nodes or on edges. **dot2dot** is
written in Python and requires Python 3 to be executed.

Usage
-----
To execute this tool, simply launch the line tool:

    ./dot2dot.py [graph] [options]
    where:
        graph must be a graphviz graph with dot format
        see -h to get help on the options
        reads from standard input if no graph is provided.

For example run `./dot2dot.py example.dot -n label="%a%, %b%" -e label=edge`. This line tool returns a graph with dot format whose edges are labelled "edge" and whose
nodes are labelled *"%a%, %b%"* where *%a%* and *%b%* are replaced by the values of their attributes
*a* and *b*. If a node doesn't possess an attribute *a* or *b*, the value will be replaced by "".

The options can be used more than once in a line tool and the values considered will be the values of the
original graph given as parameter.
