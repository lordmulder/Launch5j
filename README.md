![Launch5j](etc/logo.png)  

**Java JAR wrapper for creating Windows native executables  
created by LoRd_MuldeR &lt;<mulder2@gmx.de>&gt;**

# Introduction

**Launch5j** is a reimagination of “Launch4j”, *with full Unicode support*. This is a tool for wrapping Java applications distributed as JARs in lightweight Windows native executables. The executable can be configured to search for a certain JRE version or use a bundled one. The wrapper also provides better user experience through an application icon, a native pre-JRE splash screen, and a Java download page in case the appropriate JRE cannot be found.

# Usage

There currently are two different ways to use Launch5j with your application code:

* ***Use the launcher executable with a separate JAR file***  
  
  Simply put the launcher executable (`launch5j.exe`) and your JAR file into the same directory. Launch5j will automatically detect the path of the JAR file based on the location of the executable file. More specifically, Launch5j detects the full path of the executable file and then replaces the `.exe` file extension with a `.jar` file extension. Of course, you can rename the `launch5j.exe` executable to whatever you prefer.

* ***Combine the launcher executable and the JAR file (“wrapping”)***  

  In order to combine the launcher executable (`launch5j_wrapped.exe`) and the JAR file to a *single* file, you can simply concatenate these files. The executable launcher must go before the JAR file content. There are many ways to achieve this, but one method is by running the following *copy* command-line in the terminal:

      copy /B launch5j_wrapped.exe + my_program.jar my_program.exe

  If you are building you application with Apache Ant, consider using the `concat` task like this:
  
      <concat destfile="my_program.exe" binary="true">
         <fileset file="launch5j_wrapped.exe"/>
         <fileset file="my_program.jar"/>
      </concat>

  The resulting `my_program.exe` will be fully self-contained and is the only file you'll need to ship.

  **Warning:** Code signing, as with Microsoft&reg;'s `SignTool`, probably does **not** work with the “wrapped” executable file! If code signing is a requirement, please use a *separate* JAR file and just sing the launcher executable.

# Variants

Launch5j executables come in a number of variants, allowing you to pick the most suitable one for you project:

* **`wrapped`**  
  Expects that the JAR file and the executable launcher have been combined to a *single* file; default variant expects that a separate JAR file is present in the same directory where the executable launcher resides.

* **`registry`**  
  Tries to automatically detect the install path of the JRE from the Windows registry; default variant expects the JRE to be located in the `/runtime` path relative to the location of the executable launcher.

* **`java<N>`**  
  When detecting the JRE install path from the Windows registry, accepts *only* JRE version **N.0** or any newer JRE version; default variant accepts *only* JRE version **8.0** (1.8.0) or any newer JRE version.

* **`only[32|64]bit`**  
  When detecting the JRE install path from the Windows registry, accepts *only* 32-Bit (x86) or *only* 64-Bit (x64) JRE versions, respectively; default variant accepts 32-Bit *and* 64-Bit versions with a preference to 64-Bit.

* **`nowait`**  
  Does **not** keep the launcher executable alive while the application is running; default variant keeps the launcher executable alive until the application terminates and then forwards the application's exit code.

* **`nosplash`**  
  Does **not** display a splash screen while the application is launching; default variant *does* display a splash screen while the application is launching &ndash; will be hidden as soon as application window shows up.

## Platforms

All of the above Launch5j variants are available as `i586` (32-Bit) and `x86-64` (64-Bit) executables. The `i586` (32-Bit) executables can run on *32-Bit* and *64-Bit* versions of Microsoft&reg; Windows&trade;, whereas the `x86-64` (64-Bit) executables necessarily require a *64-Bit* version of Microsoft&reg; Windows&trade;. Consequently, it is generally recommended to distribute the `i586` (32-Bit) launcher executable with your Java application. Please note that this does **not** restrict the “bitness” of the JRE that can be used. Even the `i586` (32-Bit) launcher executable is perfectly able to detect and launch a *64-Bit* JRE &ndash; if it is available.

Launch5j has been tested to work on Windows XP (Service Pack 2), or a compatible newer version.

# Customizations

Launch5j comes with a *default* executable icon and a *default* splash screen bitmap. These just server as an example and you probably want to replace them with your own *application-specific* graphics.

It is *not* necessary (though possible) to re-build the executable files for that purpose. Instead, you can use the excellent [**Resource Hacker&trade;**](http://www.angusj.com/resourcehacker/) utility to “edit” the pre-compiled executable files and *replace* resources as needed:  

![reshack](etc/reshacker-example.png)

## Additional options

Some options can be configured via the launcher executable's [STRINGTABLE](https://docs.microsoft.com/en-us/windows/win32/menurc/stringtable-resource) resource:

* **`ID_STR_HEADING` (#1)**  
  Specifies a custom application description that will be used, for example, as title of message boxes.

* **`ID_STR_JVMARGS` (#2)**  
  Specifies *additional* options JVM options to be passed, e.g. `-Xmx2g` or `-Dproperty=value`.  
  See here for a list of available options:  
  https://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html

* **`ID_STR_CMDARGS` (#3)**  
  Specifies *additional* (fixed) command-line options to be passed to the application.  

*Note:* The default value `"?"` means "nothing" should be passed, because resource strings cannot be empty!

# Build instructions

In order to build Launch5j from the sources, it is recommended to use the [*GNU C Compiler* (GCC)](https://gcc.gnu.org/) for Windows, as provided by the [*Mingw-w64*](http://mingw-w64.org/) project. Other C compilers may work, but are **not** officially supported.

Probably the most simple way to set up the required build environment is by installing the [**MSYS2**](https://www.msys2.org/) distribution, which includes *GCC* (Mingw-w64) as well as all the required build tools, such as *Bash* and *GNU make*.

Please make sure that the essential development tools and the MinGW-w64 toolchains are installed:

    $ pacman -S base-devel
    $ pacman -S mingw-w64-i686-toolchain mingw-w64-x86_64-toolchain

Once the build environment has been set up, just run the provided Makefile:

    $ cd /path/to/launch5j
    $ make

*Note:* In order to create 32-Bit or 64-Bit binaries, use the `mingw32` or `mingw64` sub-system of MSYS2, respectively.

# Acknowledgment

This project is partly inspired by the “Launch4j” project, even though it has been re-written from scratch:  
<https://sourceforge.net/p/launch4j/>

# License

This work has been released under the MIT license:

    Copyright 2020 LoRd_MuldeR <mulder2@gmx.de>

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
