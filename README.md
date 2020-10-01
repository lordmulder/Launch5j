![Launch5j](etc/logo.png)  

**Java JAR wrapper for creating Windows native executables  
created by LoRd_MuldeR &lt;<mulder2@gmx.de>&gt;**

# Introduction

**Launch5j** is a reimagination of “Launch4j”, *with full Unicode support*. This is a tool for wrapping Java applications distributed as JARs in lightweight Windows native executables. The executable can be configured to search for a certain JRE version or use a bundled one. The wrapper also provides better user experience through an application icon, a native pre-JRE splash screen, and a Java download page in case the appropriate JRE cannot be found.

# Usage

There currently are two different ways to use Launch5j with your application code:

* ***Use the launcher executable with a separate JAR file***  
  
  Simply put the launcher executable (`launch5j.exe`) and your JAR file into the same directory. Launch5j will automatically detect the path of the JAR file based on the location of the executable file. More specifically, Launch5j detects the full path of the executable file and then replaces the `.exe` file extension with a `.jar` file extension. Of course, you can rename the `launch5j.exe` executable to whatever you prefer.
  
  *For example:* If you application's JAR file is called `bazinga.jar`, pick the Launch5j variant of your choice, rename the Launch5j executable to `bazinga.exe`, and put these two files (JAR + EXE) into the “install”directory.

* ***Combine the launcher executable and the JAR file (“wrapping”)***  
  
  In order to combine the launcher executable (`launch5j_wrapped.exe`) and the JAR file to a *single* file, you can simply concatenate these files. The executable launcher must go before the JAR file content. There are many ways to achieve this, but one method is by running the following **copy** command-line in the terminal:
  
      copy /B launch5j_wrapped.exe + bazinga.jar bazinga.exe
  
  If you are building you application with [**Apache Ant**](https://ant.apache.org/), consider using the `concat` task like this:
  
      <concat destfile="bazinga.exe" binary="true">
         <fileset file="launch5j_wrapped.exe"/>
         <fileset file="bazinga.jar"/>
      </concat>

  The resulting `bazinga.exe` will be fully self-contained and is the only file you'll need to ship.

  **Warning:** Code signing, as with Microsoft&reg;'s `SignTool`, probably does **not** work with the “wrapped” executable file! If code signing is a requirement, please use a *separate* JAR file and just sing the launcher executable.

# Variants

Launch5j executables come in a number of variants, allowing you to pick the most suitable one for you project:

* **`wrapped`**  
  Expects that the JAR file and the executable launcher have been combined to a *single* file; default variant expects that a separate JAR file is present in the same directory where the executable launcher resides.

* **`registry`**  
  Tries to automatically detect the install path of the JRE from the Windows registry; default variant expects the JRE to be located in the `/runtime` path relative to the location of the executable launcher.

* **`nowait`**  
  Does **not** keep the launcher executable alive while the application is running; default variant keeps the launcher executable alive until the application terminates and then forwards the application's exit code.

* **`nosplash`**  
  Does **not** display a splash screen while the application is launching; default variant *does* display a splash screen while the application is launching &ndash; will be hidden as soon as application window shows up.

## Platforms

All of the above Launch5j variants are available as `x86` (32-Bit) and `x64` (64-Bit) executables. The `x86` (32-Bit) executables can run on *32-Bit* and *64-Bit* versions of Microsoft&reg; Windows&trade;, whereas the `x64` (64-Bit) executables require a *64-Bit* version of Microsoft&reg; Windows&trade;. Consequently, it is generally recommended to distribute the `x86` (32-Bit) launcher executable. Please note that this does **not** restrict the “bitness” of the JRE that can be used. Even the `x86` (32-Bit) launcher executable is perfectly able to detect and launch a *64-Bit* JRE &ndash; if it is available.

*Note:* Launch5j has been tested to work correctly on Windows XP (Service Pack 2), or a compatible newer version.

# Customizations

Launch5j comes with a *default* executable icon and a *default* splash screen bitmap. These just server as an example and you probably want to replace them with your own *application-specific* graphics.

It is ***not*** necessary to re-build the executable files for that purpose. Instead, you can simply use a resource editor, such as [**XN Resource Editor**](https://web.archive.org/web/20100419201225/http://www.wilsonc.demon.co.uk/d10resourceeditor.htm) ([mirror](https://stefansundin.github.io/xn_resource_editor/)) or [**Resource Hacker&trade;**](http://www.angusj.com/resourcehacker/), to *modify* the pre-compiled executable files as needed:  

![reshack](etc/reshacker-example.png)

## Additional options

Some options can be configured via the launcher executable's [STRINGTABLE](https://docs.microsoft.com/en-us/windows/win32/menurc/stringtable-resource) resource:

* **`ID_STR_HEADING` (#1)**  
  Specifies a custom application title that will be used, e.g., as the heading of message boxes.

* **`ID_STR_JVMARGS` (#2)**  
  Specifies *additional* options JVM options to be passed, such as `-Xmx2g` or `-Dproperty=value`.  
  See here for a list of available options:  
  <https://docs.oracle.com/javase/7/docs/technotes/tools/windows/java.html>

* **`ID_STR_CMDARGS` (#3)**  
  Specifies *additional* fixed command-line parameters to be passed to the Java application.  

* **`ID_STR_JREPATH` (#4)**  
  Specifies the path to the Java runtime (`javaw.exe`) relative to the launcher executable location.
  If not specified, then the *default* runtime path `runtime\\bin\\javaw.exe` is assumed.

  (This option does **not** apply to the “registry” variant of Launch5j)

* **`ID_STR_MUTEXID` (#5)**  
  Specifies the application ID to be used when creating the [*single-instance*](http://www.bcbjournal.org/articles/vol3/9911/Single-instance_applications.htm) mutex.  
  The ID **must** be at least 5 characters in length and **should** be a *unique* string for each application!  
  If not specified, then **no** mutex will be created and thus *multiple* instances will be allowed.
  
  *Hint:* If the specified application ID *starts* with an **`@`** character, then Launch5j will **not** show a message box when the application is already running; the **`@`** character is *not* considered a part of the actual ID.

  (This option does **not** apply to the “nowait” variant of Launch5j)

* **`ID_STR_JAVAMIN` (#6)**  
  Specifies the ***minimum*** supported JRE version, in the **`w.x.y.z`** format (e.g. `11.0.0.0`).  
  This values is *inclusive*, i.e. the specified JRE version or any newer JRE version will be accepted.  
  If not specified, then the *default* minimum supported JRE version `8.0.0.0` applies.

  *Hint:* Old-style `1.x.y_z` Java versions  are automatically translated to the new `x.y.z` format!

  (This option only applies to the “registry” variant of Launch5j)

* **`ID_STR_JAVAMAX` (#7)**  
  Specifies the ***maximum*** supported JRE version, in the **`w.x.y.z`** format (e.g. `12.0.0.0`).  
  This values is *exclusive*, i.e. only JRE versions *older* than the specified JRE version will be accepted.  
  If not specified, then there is **no** upper limit on the supported JRE version.
  
  *Hint:* Old-style `1.x.y.z` Java versions are automatically translated to the `x.y.z.0` format!
  
  (This option only applies to the “registry” variant of Launch5j)

* **`ID_STR_BITNESS` (#8)**  
  Specifies the required ***bitness*** of the JRE. This can be either **`32`** (x86, aka i586) or **`64`** (x86-64).  
  If not specified, then 32-Bit *and* 64-Bit JREs are accepted, with a preference to 64-Bit.
  
  (This option only applies to the “registry” variant of Launch5j)

* **`ID_STR_JAVAURL` (#9)**  
  The Java download URL that will ne suggested, if **no** suitable JRE could be detected on the machine.  
  If not specified, wes suggest downloading OpenJDK as provided by the [AdoptOpenJDK](https://adoptopenjdk.net/) project.

  *Hint:* The URL must begin with a `http://` or `https://` prefix; otherwise the URL will be ignored!

  (This option only applies to the “registry” variant of Launch5j)

*Note:* We use the convention that the default resource string value `"?"` is used to represent an “undefined” value, because resource strings cannot be empty. You can replace the default value as needed!

# Unicode command-line arguments

There is a *long-standing* bug in Java (on the Windows&trade; platform), which causes *Unicode* command-line arguments to be “mangled”. More specifically, even if the Unicode command-line arguments are properly passed to the Java executable (`java.exe`), they are **not** forwarded correctly to the `main()` method of your Java program!

Instead, any characters that can **not** be represented in the computer's *local* ANSI codepage (pretty much any *non*-ASCII characters) are replaced by **`?`** characters. The cause of the problem apparently is that the “native” C code of the Java executable still uses the *legacy* `main()` entry point instead of the [`wmain()`](https://docs.microsoft.com/en-us/cpp/c-language/using-wmain?view=vs-2015) entry point. The latter is the modern Unicode-aware entry point that applications written for *Windows 2000 and later* **should** be using &ndash; ouch!

As a workaround, Launch5j will convert the given Unicode command-line arguments to the UTF-8 format and then apply [URL encoding](https://en.wikipedia.org/wiki/Percent-encoding) on top of that. This ensures that *only* pure ASCII characters are passed to the Java executable, thus preventing the command-line from being “mangled”. Still the original Unicode arguments can be reconstructed.

The only downside is that a bit of additional processing will be required in the application code:

```
public class YourMainClass {
  public static void main(final String[] args) {
    decodeCommandlineArgs(args);
    /* your application code goes here! */
  }

  private static void decodeCommandlineArgs(final String[] argv) {
    if (System.getProperty("l5j.pid") == null) {
      return; /* nothing to do, if not started by L5j */
    }
    for (int i = 0; i < argv.length; ++i) {
      try {
        argv[i] = URLDecoder.decode(argv[i], StandardCharsets.UTF_8);
      } catch (Exception e) { }
    }
  }

  /* ... */
}
```

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


[&#8718;](https://www.youtube.com/watch?v=EfbbjY9MlQs)
