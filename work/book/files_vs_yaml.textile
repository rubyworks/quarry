h1. On Configuration Storage Format for Project Metadata

h2. Ruby Script

Ruby-scripts as configuration is popular among gung-ho Ruby-enthusiests. And there is certainly
some merit to it's use, but along with the powerful advantages are serious disadvantages as well.

h3. Advantages

* Computable settings is very flexiable.
* Support full type support --Array, String, Integer, etc.

h3. Disadvantages

* Using Ruby code as configuration limits their use to Ruby programs.
* Providing the full power of a scriptling language presents a higher security risk.
* Automated modification of configuration scripts is difficult.

Ruby scripts are not an uncommon configuration format, especailly in the area of
project tools --.gemspec files for instance are Ruby scripts. Their greatest advantage
is in their flexability --properties can be set computationally. However, the issues
of interoperability, security and editing automation make them a very limited
option.


h2. YAML

In the world Ruby programming YAML is certainly the most common choice
of configuration storage. Since YAML is a human-readable serialization format,
this stand to reason.

h3. Advantages

* Popular format amoung Rubyists; and becoming more popular with other languages.
* Supports serialization types (string, array, hash, integer, time, etc).
* Easy to en masse edit, as all settings can be in a single file.

h3. Disadvantages

* Requires dependency on a hefty parser library.
* Difficult to automate selective modification. (Whole file needs to rewritten.)

YAML has the advantage of en masse editing, which will certainly seems more comfortable
to the average Ruby coder. However, this advantage is limited primarily to first-time
editing of configuration data since, in our usecase, most properties will not
change once set.

YAML also has the advantage of supporting of basic types like String, Array, Hash,
and, in the Syck implementation, Time and Integer as well. These types provide some
extra information that can be used in determining the value of a property. However,
this also opens us up to greater potenial of data-type errors.


h2. INI

h3. Advantages

* INI files are very human readible and easy to edit.

h3. Disadvantages

* Requires parser library (but much smaller than YAML's).
* Entries are generally limited to a single line entry.
* No data types --all data are strings.

INI files are even easier to read and write than YAML files. However they lack
serialization types. So all properties are strings and it's up to the application
to determine the type of data.  Also, on the whole entries are limited
to a single line. This means list entries usually need to be separated by
a deliminator [,:;], and long description entries need special consideration.

While INI files are conceptually simpler than YAML files, and in so being are
a more attractive solution (IMO), the difference between YAML and INI
does not seem great enough to warrant their use over the convention of
Rubyists to use YAML instead.


h2. Per-Property Files

The use of one file per property has some significant advantages, but likewise
has a few issues that keep it from being a perfect solution.

h3. Advantages

* No special parser library is required.
* Individual file can be selectively loaded.
* Very easy to automate selective update.
* Usable by any language or tool.

h3. Disadvantages

* Cumbursome to edit properties en masse.
* No data types --all data are strings (unless we use file extensions).
* Wastes file system space (ie. block size).
* Not as easily scrapable by search engines.
* Highly unconventional appraoch.

While some may take serious issue with the waste of file system space, this is increasingly
a negligable downside. Some modern file systems handle small files quite gacefully, and
the number of potential properties limits the waste in anycase.

While not being able to easily edit en masse might seem like a show-stopper, for this
usecase it is usually only needed for the initial editing. After that, editing metadata
tends to be very selective.

While per-propery files do not support data types per-se, if neccessary file extensions on
header comment lines (shebang lines) could be used to convey type.

Probably the biggest downside to the per-propery file approach though is the lack of convention
for doing so. It no doubt will strike most developers as a "bad thing", at least at first.


h2. Analysis

In considering the possible configuration formats, it becomes clear there are trade-offs.
No solution is perfect, but no solution is without it's merits either.



