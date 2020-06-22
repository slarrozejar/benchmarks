import argparse
import string

parser = argparse.ArgumentParser()
parser.add_argument("-n", "--nodes", type=str, nargs=2,
                    help="apply changes on nodes")
parser.add_argument("-e", "--edges", type=str,
                    help="apply changes on edges")
args = parser.parse_args()
if(args.nodes):
    # print(args.nodes)
    n=args.nodes[1]
# else:
#     print(args.nodes)
# if(args.edges):
#     print(args.edges)
# else:
#     print(args.edges)

attribute_to_replace = args.nodes[0]

initial=n
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

attributes_values = [] # Names of attributes' values we consider
for i in range(len(lb)):
    attributes_values.append(initial[lb[i]+1:up[i]])
