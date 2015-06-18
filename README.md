streamsx.mongoDB
================
This toolkit provides support for [MongoDB](http://www.mongodb.org).
Web page with SPLDoc for operators and samples: [streamsx.mongoDB SPLDoc](http://ibmstreams.github.io/streamsx.mongoDB).

Support for Streams 4.0 Now Available!

Setup (For Streams 3.2.1 branch only)
-----
The toolkit needs write permissions for SPL developer.

When creating a new build, the following flag should be placed in 'Other' -> 'C++ compiler options':  '-fno-strict-aliasing'.
It prevents strict-aliasing warnings from mongodb header files.
