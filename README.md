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

To learn more about Streams:
* [IBM Streams on Github](http://ibmstreams.github.io)
* [Introduction to Streams Quick Start Edition](http://ibmstreams.github.io/streamsx.documentation/docs/4.1/qse-intro/)
* [Streams Getting Started Guide](http://ibmstreams.github.io/streamsx.documentation/docs/4.1/qse-getting-started/)
* [StreamsDev](https://developer.ibm.com/streamsdev/)
