#List of interview questions

## General
### Experiences
 * What are your experiences with [Product], and how do you rate your knowledge here
   * Check how the interviewee estimates his own knowledge and how he reacts  
 * 

## MQ
### Administration
* How do you connect 2 qmgrs witch each other?
    * channel sec/rec
    * remote q
    * transmit q
* Describe how you can manage a qmgr
  * mq web
  * runmqsc
  * rest api
  * mq explorer
* How familiar are you with runmqsc
    * how do you
        * create a queue
        * query a queue
        * display queue depth
        * ...
* Describe one keypoint when installing and configuring a qmgr
    * logging ...

### Security
* How do you setup mq security
    * channel authentication
    * admin authentication (ldap)
    * ...

### Concepts
* Describe how mq pub/sub works
* Describe how mq clusters work?
* Describe how pub/sub works in mq clusters
* Describe the mq backout mechanism
    * backout count and dlq
* Describe the structure of a mq message
    * mqmd, mqrfh2, ...
* Describe MQ unit of work
* Describe persistent messages
    * how does it work
    * how do you set it up
* Describe the difference between linear and circular logging
 
### High availability
 * Describe mq high availability
   * Active/passive aka multi instance
   * is this the same as HA? If not how can you achieve HA?
     * what is the biggest issue with MI
   * MQ RDQM
   * ...
 * What kinds of high availability setups do you know for mq on cloud 
   * ...


## ACE
### Administration
* What versions of WMB/IIB/ACE have you used?
* Do you know what the latest release of ACE is?
* Do you know at what rate IBM releases new ACE versions?
* What are these ACE versions called?
* How familiar are you with the command line?


### Security
* How do you enable administration security for ACE
  * Authorization vs authentication
  * File based vs ldap
* What 2 ways are there to securely store credentials?
  * DBparms and vault

### Concepts
* What do you know about ACE monitoring events
  * How do you set them up? Policies/monitoring tab, mq topics and pub/sub, ...
* Trace nodes in production yes/no why?
  * No because it impacts performance because of a full parsing of the memory
  * Yes because it is more easy and less impact to activate then full blown debugging
* What is the advantage of using the BLOB parser?
  * best performance
  * no impact of code changes
  * can contain full images/pdf/...
* Describe the concept of unit of work inside a message flow?
* Describe what happens when an exception occurs towards the end of a message flow?
* How do you set transactional messages in ACE and what does it mean?
* Describe the requirements to deploy a HTTPS flow
  * node properties set to https, keystore, truststore
* What type of policies do you know? Dynamic vs non-dynamic
  * What impact do non-dynamic policies have?
  * How can you work around this issue?
    * manually drag and drop to the runtime + restart
    * Deploy + option --restart-all-applications
* What are callable flows and how do they work
  * What is a key security point here? The connection is initiated internally towards externally.
  * What does a switch server do?
### High availability
* Explain Multi instance
  * is this the same as HA? If not how can you achieve HA
  * what is the biggest issue with MI?

### Problem solve
* A message flow is experiencing bad performance, how do you search the node that is the problem?
  * Activate statistics and check processing time
* How do you increase the throughput of a flow that handles small sized messages
  * additional instances
* Ho do you increase the throughput of a flow that handles large sized messages
  * deploy flow in parallel execution group

### Development
* How can you override node properties?
  * via the local environment
* How can you dynamically choose what queue to write to?
  * ...
* Are you familiar with Java in ACE? 
  * What are the differences with the CMP in ACE
* A flow handles xml messages but does not need to transform or read the content.. Which parser do you use.. Why?
  * BLOB, best performance no parsing.
* What are 4 ways of creating a bar file
    * Toolkit
    * mqsipackagebar
    * mqsicreatebar
    * ibmint package 
* Explain
  * mqsiapplybaroverrid
  * mqsireload
  * 
* How do you start setting up db connections on windows/linux
  * odbc.ini (lnx) or odbc data sources (win)
  * mqsisetdbparms
  * data source on esql or db node
* How do you debug issues with database connections
  * ...
* For a simple message flow, queue in and out, basic funcionality in the middle, no catch or fail terminals attached, what happens when an error occurs towards the end of the flow?
* How would you handle very big files in an ace flow?
  * big file pattern ...

## Cloud


 