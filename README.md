The Maven repository cleaner (bash script), which keeps only the latest versions of artifacts.

# What is this tool?

Maven is a great software project management and comprehension tool, in particular because it manages its own dependencies (plugins) as well as your project's dependencies neatly by separating between what your project _really_ does and the artifacts required to build, test, package and release it.

It is best practice to keep your Maven dependencies up to date, as newer versions tend to fix bugs (including security issues), which you can achieve by:

* Doing it yourself, by running `mvn versions:display-dependency-updates` and `mvn versions:display-plugin-updates` regularly
... and/or
* Relying on tools such as Dependabot (which, if your code is on Github, will be running in the background anyway)

One downside of Maven's methodology is that as these artifacts evolve in time, and hence your project and plugin dependencies' versions change over time, your Maven local repository will have the older versions you built with and the new versions you upgraded to; which means it will grow bigger, and bigger, and bigger. This is usually not a problem on your local environment as storage tends to be quite cheap these days, on the other hand if you are using a shared Continous Integration platform (such as Semaphore CI or Travis CI) you might feel the pain because the Virtual Machine allocated to your build is very likely to take longer to be initialized, and in some cases the CI might stop caching your Maven dependencies altogether because it goes beyond what they provide you as cache - Both slowing down the reactiveness of your Continous Development process.

# Why this tool? There are already many answers to this problem when I search on my favorite search engine!

I did spend some hours looking at this problem and to the answers, many of them rely on the `atime` (which is the last access time on UNIX systems), which is an unreliable solution for two reasons:

1. Most UNIX systems (including Linux and macOS) update the `atime` irregularly at best, and that is for a reason: a complete implementation of `atime` would imply the whole file system would be slowed down by having to update (i.e., write to the disk) the `atime` every time a file is read, moreover having a such an extreme number of updates would very rapidly wear out the modern, high performance SSD drives
1. On a CI/CD environment, the VM that's used to build your Maven project will have its Maven repository restored from a shared storage, which in turn will make the `atime` get set to a "recent" value

# How does this tool work?

The bash `maven-repository-cleaner.sh` script has one function, `cleanDirectory`, which is a recursive function looping through the `~/.m2/repository/` and does the following:

* When the subdirectory is not a version number, it digs into that subdirectory for analysis
* When a directory has subdirectories which appear to be version numbers, it only deletes all lower versions

In practice, if you have a hierarchy such as:

* `artifact-group`
  * `artifact-name`
    * `1.8`
    * `1.10`
    * `1.2`

... `maven-repository-cleaner.sh` script will:

1. Navigate to `artifact-group`
1. In `artifact-group`, navigate to `artifact-name`
1. In `artifact-name`, delete the subfolders `1.8` and `1.2`, as `1.10` is superior to both `1.2` and `1.8`

# How do I run this tool in my CI/CD environment?

Just use the below three lines, either at the beginning or at the end of the build:

```
wget https://raw.githubusercontent.com/alitokmen/maven-repository-cleaner/main/maven-repository-cleaner.sh
chmod +x maven-repository-cleaner.sh
./maven-repository-cleaner.sh
```
# Does the tool have limitations?

AFAIK, two limitations:

1. The start directory is `~/.m2/repository/`
1. Though the tool does its best to reorder `alpha`, `beta`, etc. versions it might not be perfect

# What is the license?

This tool is licensed under the MIT License, which means that:

* There are no warranties, if anything breaks you can't hold me responsible for it
* You can do "pretty much anything" with the tool, without having to ask me, including cloning, modifying and even selling it
