# BETL

Welcome to BETL, an open source ETL automation engine, written in 100% T-SQL (MS SQL Server). The main reasons for using BETL are:

 * It will improve your productivity considerably
 * Improve the quality of your ETL ( because the ETL is generated, there is little room for accidental mistakes). 
 * Makes your work more fun, because it takes away the repetitive tasks ( no more copy-pasting of ETL code). 

Compared to other ETL automation tools like BIML, BETL is pretty simple. It's just a database containing meta data and procedures. It will generate ETL code by using templates. The learning curve is relatively small. However some knowledge of T-SQL is required.  

## What is BETL

* Free, open source, GNU GPL
* Meta data driven ETL automation engine (it generates T-SQL)
* Simple (it only depends on SQL server. No dependency on SSIS or an external tool. However it can be used together with SSIS).
* Time saving (look and see)
* Generic (usable in many different scenarios)

## What is BETL NOT

* A modeling method (like e.g. Datavault or Anchor modeling)
* Restrictive (all or nothing)
* A DWH architecture
* Visual (currently it's only TSQL, but you can integrate it in SSIS)

## Current Status

* BETL is currently being used by 2 large customers in The Netherlands. The current version is optimized for generating Datavault tables (Hubs, Sats and Links). For each new Customer BETL is extended and modified according to the current needs.

## Strong elements of BETL are:

* the meta data engine ( storing meta data about tables and columns).
* guessing. We believe that user input should be minimized. If we can guess for example the target column for a natural foreign key then we will do that. Of course you can always modify the meta data when guessing was not correct.
* dynamic SQL generation using parameters. Bound to the limits of stored procedures we try to develop as modular as possible. 
* simple to use and extend. (Most extension work is done on stored procedure push).
* It forces developers to folow certain design guidelines and best practices. E.g. naming conventions, change detection, logging, TSQL Batch insert performance, etc.

## How it works
The goal of BETL is making the life of ETL developers easier.
Suppose you want to move data from A to B. Where A is a table or a view and B is a target table in the target schema.

What we need is the following:
* connection to A (e.g. by using a linked server using an OLEDB driver)
* connection to B
* Some meta data about the transfer that cannot be derived from the source (like template_id and which columns form a natural key). 

template_id tells us which ETL template should be chosen for transfering A to B. the natural keys tells us which columns can be used e.g. for change detection. 

To execute the transfer we execute the following T-SQL:

    exec betl.push ‘A’ 

we assume that the schema where A lives has a default target schema which will be used by BETL to determine B. The table name for B can also be defined by the template. 

BETL uses extensive logging, so you can see what happens. Debugging is also easy. Just switch on the debugmode and invoke this command in management studio. You will get the SQL that will be executed. 

Continue with [BETL Architecture](BETL-Architecture)
Please visit our wiki for getting started. https://github.com/basvdberg/BETL/wiki
go directly to getting started: https://github.com/basvdberg/BETL/wiki/Getting-started

## Latest news

# GDPR
Currently I am working to integrate GDPR (general data protection regulation) reporting into betl. Because BETL is meta data based adding lineage is relatively easy, however this can be tricky when using stored procedures, views or ssis to transform your data. Nevertheless we have done a pretty good job at discovering most dependencies including SSAS Tabular Cube meta data and Active directory. (Send me an email for more info..)

# presentation at Bi-united September 2017 
Have a look at our [presentation](http://slides.com/mr_bas/betl#/) at [Bi-united](http://www.bi-united.nl/)) 
