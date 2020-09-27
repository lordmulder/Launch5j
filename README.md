![Launch5j](etc/logo.png)  

**Java JAR wrapper for creating Windows native executables  
created by LoRd_MuldeR &lt;<mulder2@gme.de>&gt;**

# Introduction

**Launch5j** is a reimagination of “Launch4j”, *with full Unicode support*. This is a tool for wrapping Java applications distributed as JARs in lightweight Windows native executables. The executable can be configured to search for a certain JRE version or use a bundled one. The wrapper also provides better user experience through an application icon, a native pre-JRE splash screen, and a Java download page in case the appropriate JRE cannot be found.

# Usage

There currently are two different ways to use Launch5j with your application code:

* ***Use the launcher executable with a separate JAR file***  
  
  Simply put the launcher executable (`launch5j.exe`) and your JAR file into the same directory. Launch5j will automatically detect the path of the JAR file based on the location of the executable file. More specifically, Launch5j detects the full path of the executable file and then replaces the `.exe` file extension with a `.jar` file extension. Of course, you can rename the `launch5j.exe` executable to whatever you prefer.

* ***Combine the launcher executable and the JAR file (“wrapping”)***  

  In order to combine the launcher executable (`launch5j.wrapped.exe`) and the JAR file to a *single* file, you can simply concatenate these files. The executable launcher must go before the JAR file content. There are many ways to achieve this, but one method is by running the following *copy* command-line in the terminal:

      copy /B launch5j.wrapped.exe + my_program.jar my_program.exe

  The resulting `my_program.exe` will be fully self-contained and is the only file you'll need to ship.

  **Warning:** Code signing, as with Microsoft&reg;'s `SignTool`, probably does **not** work with the “wrapped” executable file! If code signing is a requirement, please use a *separate* JAR file and just sing the launcher executable.

# Variants

Launch5j executables come in a number of variants, allowing you to pick the most suitable one:

* **`wrapped`**  
  Expects that the JAR file and the executable launcher have been combined to a *single* file; default variant expects that a separate JAR file is present in the same directory where the executable launcher resides.

* **`registry`**  
  Tries to automatically detect the install path of the JRE from the Windows registry; default variant expects the JRE to be located in the `/runtime` path relative to the location of the executable launcher.

* **`java11`**  
  When detecting the JRE install path from the Windows registry, accepts only JRE version 11 or any newer JRE version; default variant accepts only JRE version 8 (1.8.0) or any newer JRE version.

* **`nosplash`**  
  Does **not** display a splash screen while the application is launching; default variant *does* display a splash screen while the application is launching (will be hidden as soon as application window shows up).

* **`nowait`**  
  Does **not** keep the launcher executable alive while the application is running; default variant keeps the launcher executable alive until the application terminates and then forwards the application's exit code.

# Customizations

Launch5j comes with a *default* executable icon and a *default* splash screen bitmap. These just server as an example and you probably want to replace them with your own *application-specific* graphics.

It is *not* necessary (though possible) to re-build the executable files for that purpose. Instead, you can use the excellent **Resource Hacker&trade;** utility to “edit” the pre-compiled executable files as needed:  
<http://www.angusj.com/resourcehacker/>

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
