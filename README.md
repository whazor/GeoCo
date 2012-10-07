GEOCO
=====
Installeren
-----------

### Installing Java:

- Download the JDK installer for Windows from http://www.oracle.com/technetwork/java/javase/downloads/jdk7u7-downloads-1836413.html
- Run the installer
- Add the bin\ directory of the installed JDK to the PATH environment variable, as described here: http://www.java.com/en/download/help/path.xml

### Scala:

- http://scalasbt.artifactoryonline.com/scalasbt/sbt-native-packages/org/scala-sbt/sbt/0.12.0/sbt.msi

### Eclipse:

 - http://www.eclipse.org/downloads/packages/release/indigo/sr2 -> Eclipse IDE for Java Developers
 - http://scala-ide.org/download/current.html
 - https://github.com/adamschmideg/coffeescript-eclipse

### Play framework:

- http://www.playframework.org/documentation/2.0.4/Installing

### Database:

- http://www.postgresql.org/download/windows/
- http://postgis.refractions.net/download/windows/
- http://mycel.nl/gelderland.gz (420mb)

De database maken:

    CREATE DATABASE osmosis;
    USE osmosis;
    CREATE EXTENSION postgis;
    CREATE EXTENSION hstore;
    CREATE DATABASE geoco;
    USE geoco;
    CREATE EXTENSION postgis;

Daarna het Gederland.gz bestand inladen op de osmosis database.

Usefull links
-------------

- http://www.scala-lang.org/api/
- http://twitter.github.com/scala_school/
- http://docs.scala-lang.org/tutorials/tour/tour-of-scala.html
- http://stackoverflow.com/tags/scala/info

