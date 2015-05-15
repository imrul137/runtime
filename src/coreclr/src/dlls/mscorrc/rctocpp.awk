# Convert string resources from Windows native resource file to a C++
# source file with an array of structs representing the resources.

BEGIN {
    numEntries = 0;
}

# Takes a number and returns a string corresponding to its hex
# representation. A string representation that has fewer than 8
# characters (not including the '0x' prefix) is padded with 0's
# to make it 8 characters.
# Example: an input of 49 yields "0x00000031".
function numberToHexString(number)
{
    quotient = number;

    hexString = "";
    while (quotient > 0)
    {
        remainder = quotient % 16;
        quotient = int(quotient / 16);
        hexString = sprintf("%x"hexString, remainder);
    }

    lengthOfHexString = length(hexString);
    if (lengthOfHexString < 8)
    {
        hexString = substr("00000000", 1, 8 - lengthOfHexString) hexString;
    }

    hexString = "0x" hexString;
    return hexString;
}

# Add each entry that is in our associative array of entries to the
# C++ array we are building. The C++ array will be ordered by the 
# resourceId (lowest to highest) to facilitate quick lookups.
function writesortedentries()
{
    for (entry in resourceArray)
    {
        # Write the entries to the C++ array ordered by the ID.
        printf "    {%s,%s},\n", entry, resourceArray[entry] | "sort";
    }

    # Close the pipe to ensure that the data is written now.
    close("sort");
}

# Write entry for a string resource
# This is called for each entry. Because we want to write them in 
# sorted order once all the entries have come in, for now we just
# store each entry in an associative array.
function writestringentry(id, str)
{
    numEntries++;

    # Use the string representation of the ID as the array index
    # because the precision of numeric indices can be lost when
    # iterating over the array in our for-in loop.
    resourceArray[numberToHexString(id)] = str;
}

# Write file header and begin the array we will populate with the resources.
function writeheader()
{
    print "// This code was generated by rctocpp.awk and is not meant to be modified manually."
    print "#include <resourcestring.h>";
    print "";
    print "const NativeStringResource nativeStringResources[] = {";
}

# Write file footer
# This function is called after all of the entries have been given to
# writestringentry. Because we know there are no more entries, we can
# now write all the entries we received so far when this is called.
# After we have written all the entries, we close the array and add a 
# constant for the size of the array for convenience.
function writefooter()
{
    writesortedentries();
    print "};";
    print "";
    print "const int NUMBER_OF_NATIVE_STRING_RESOURCES = " numEntries ";";
}
