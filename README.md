streamsx.mongoDB
================
This toolkit provides support for [MongoDB](http://www.mongodb.org).
Web page with SPLDoc for operators and samples: [streamsx.mongodb SPLDoc](http://ibmstreams.github.io/streamsx.mongodb).

Setup
-----
The toolkit needs write permissions for SPL developer.

When creating a new build, the following flag should be placed in 'Other' -> 'C++ compiler options':  '-fno-strict-aliasing'.
It prevents strict-aliasing warnings from mongodb header files.
