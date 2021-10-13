# Boomi Splunk Configuration

These Splunk configurations will allows the collection, parsing and rendering of Boomi Log in Splunk Enterprise.



The following Logs elements are included:
- Container Logs
- Shared Web Services Logs
- Gateway Logs
- Authentication Services Logs
- Process Logs
- (Custom) Execution Logs
- (Custom) Audit Logs
- (Custom) Listener Statuses Logs
- (Custom) Schedules Logs



## Getting started

Deploy the respective configurations:

- "forwarder" folder on the Boomi Runtime
  - Atom
    - Please update the folder name to mach your Atom structure
  - Molecule
    - Please update the folder name to mach your Atom structure
    - And also update the wild-card:
      - For instance *.container.log will become *.container<nodeId>.log
- "server" and "dashboard" folders on the Splunk Server



## Overview

For an overview of the configurations and view some of the dashboards please check this [article](https://blog.antsoftware.org/boomi-monitoring-splunk/)

