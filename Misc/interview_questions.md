# List of interview questions ACE and MQ
## General
### Experiences
 * Question: What are your experiences with [Product], and how do you rate your knowledge there
   * Goal: Check how the interviewee estimates his own knowledge and how he reacts  
 * Question: Have you ever come across an issue with [Product] that you were unable to solve? How did you handle that?
   * Goal: Check how well he is able to call for help when needed.

## MQ
### Administration
* Question: How do you securely connect 2 qmgrs witch each other?
  * Answer: ...
      * setup channel authentication
      * remote q
      * transmit q
* Question: Describe how you can manage a qmgr, what tools can you use
  * Answer:
    * mq web
    * runmqsc
    * rest api
    * mq explorer
* Question: How familiar are you with runmqsc? How do you
  * Answer:
      * create a queue: def ql(AAA) 
      * query a queue: dis ql(AAA)
      * display queue depth: dis ql(AAA) curdepth
      * display queues with messages: dis ql(*) where(curdepth ge 1)
      * ...
* Question: Describe one keypoint when installing and configuring a qmgr
    * Answer: the qmgr log files, you can't change the log file size after creation, only the number of log files

### Security
* Question: How do you setup mq security for (large steps, no detailed commands)
    * channel authentication
      * Answer: Setup certificates, cipher suites, channel auth records (blockuser, addressmap, usermap), mq user, channel security exits
    * Admin authentication (ldap)
      * Answer: import ldap server cert, configure mq to use ldap (user/pass/dn/certs), refresh security
    * Question: How do you give someone access to a specific resource?
      * Answer: 
        * Check the error logs for the user name 
        * Set authentication record: SET AUTHREC PROFILE('QUEUE.NAME') OBJTYPE(QUEUE) PRINCIPAL('userid') AUTHADD(ALL)
        * Grant access to channel: SET CHLAUTH('queue-admin-channel') TYPE(USERMAP) CLNTUSER('userid') USERSRC(MAP) MCAUSER('mqm')
        * refresh security

### Concepts
* Question: Describe how mq pub/sub works
  * Answer: Publication on topic en subscription on topic string with wildcards
* Describe how mq clusters work
  * Answer: mq clusters allow for queues and publications to be shared between qmgrs in the cluster. Both for replication and availability.
* Describe how pub/sub works in mq clusters
  * Answer:
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
   * Message high availability vs system ha
   * Externally managed
     * System managed HA (containers, cloud, k8s, ...)
     * Multi instance QMGR
   * MQ managed
     * MQ appliance (pair of)
     * replicated data qmgrs on linux (HA RDQM and DR RDQM)
     * Clusters
   * containers/cloud
     * MI
     * clusters
     * Native HA
     * Uniform cluster with native ha qmgrs

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
* Are you familiar with standalone integration server?
* Explain what "ibmint optimize" does
* Explain the difference between "ibmint deploy" and "imbint package"

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
### Platforms
* what platforms are you familiar with?
  * What is you expertise/experience with each of them
    * azure
    * google cloud
    * ibm cloud
    * aws
    * ...


 