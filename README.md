# Tuxedo-samples
Sample applications using Tuxedo and related products

I'd like to see a number of potential sample applications developed.  In particular I think a simple banking application modeled after the standard Tuxedo banking application but updated to leverage the new Tuxedo features and add-ons that have been made since bankapp was originally developed.  What I'm thinking of is showcasing:

- Multiple lanugages: So services developed in each of the supported languages which currently includes C, C++, COBOL, Python, Ruby, PHP, and Java.  Perhaps even some "mainframe rehosted" transactions using ART.

- Multiple interfaces:  So both SOAP and REST based interfaces to the services.

- Multiple clients/UIs:  Web based using Jolt, Web based using Tomcat running in the Tuxedo Java server, Mobile or HTML5 using REST

# Getting Started
To get started using Tuxedo, you need to download the Tuxedo installer from the Oracle Technology Network website.  Although it is licensed software, you can play with it and develop with it under the OTN Developer License which basically allows you to use Tuxedo as long as you don't got into production with it.  Once you put the software into production, you need to license it.

The download site is: http://www.oracle.com/technetwork/middleware/tuxedo/downloads/index.html

Gary Jones has graciously create a baseline VirtualBox VM that we can use as starting point for sample development.  It can be downloaded [here](http://littles.name/tuxedodemos/TuxedoSamplesVM).  I think it makes sense to use this as a starting point, and as samples are developed, to assume the environment provided by this VM.  That means if you want to add an Oracle product that prohibits redistribution such as Tuxedo or Oracle Database, you can provide silent install answer files that match up with the configuration of this VM to make life easier for other users.

## Developing in C or C++
If you want to develop in C or C++ under Windows, you will likely need Microsoft Visual Studio Express 2010 which can be downloaded from:  http://www.visualstudio.com/downloads/download-visual-studio-vs#DownloadFamilies_4   Linux users can just use the standard gcc compiler and libraries.

## Developing in Java
If you want to develop in Java, you will need JDK 1.6 or later.  There is a sample Tuxedo Java application located in the Tuxedo installation directory (assuming you picked installing the samples) in `$TUXDIR/samples/atmi/javaapp`

## Developing in dynamic scripting languages
Tuxedo supports several dynamic scripting languages as part of the core Tuxedo installation.  They all basically use the [Service Component Architecture](http://en.wikipedia.org/wiki/Service_Component_Architecture) to define and access services.

### Developing in Python
If you want to develop in Python, you will need Python 2.x for your platform.  You can download Python from [here](https://www.python.org/downloads/)
There are sample Tuxedo Python applications at `$TUXDIR/samples/sca/calc_python` and `$TUXDIR/samples/sca/simp_python`


### Developing in Ruby
If you want to develop in Ruby, you will need Ruby 1.x, although Ruby 2.x might work. You can download Ruby from [here](https://www.ruby-lang.org/en/downloads/)
There are samnple Tuxedo Ruby applications at `$TUXDIR/samples/sca/calc_ruby` and `$TUXDIR/samples/sca/simp_ruby`

### Developing in PHP
If you want to develop in PHP, you will need PHP which can be downloaded [here](http://us2.php.net/downloads.php)


## Tuxedo and Python Tutorial
A great getting started Tutorial for Tuxedo and Python is [here](http://www.oracle.com/webfolder/technetwork/tutorials/obe/fmw/tuxedo/11g/r1/developingpythoncomponents/developingpythoncomponents.htm)
It's a little dated in that it is designed for older versions of Tuxedo, and uses SALT (which used to be required to develop Tuxedo applications in scripting languages, but no more).

## Tuxedo and PHP Virtualbox Virtual Machine
Another simple way to get started with Tuxedo is to download a developer VM from [here](http://www.oracle.com/technetwork/community/developer-vm/index.html#tux).  Again, it's a slightly older version of Tuxedo but it's a great way to get started.
