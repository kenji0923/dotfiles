# General rules
- When you execute programs for requested purpose, always put summary of for what purpose you execute them and how to do them through command line. Find the appropriate location to put that. If not found, doc/command.md.

# Coding rules
## C++
- Follow C++17 standard.
- Follow Google C++ coding style.
- If reasonable follow project structure defined in https://github.com/kenji0923/cppprojbuilder. Usually be in .local/cppprojbuilder or somewhere. If not present, prompt the user.
### CERN ROOT
- When projects are using CERN ROOT library, use https://github.com/kenji0923/roothelper for data management and plot formating. If this repo is not present, prompt the user.
- Use sentence case for axes titles.
- Default linewidth should be 1.
