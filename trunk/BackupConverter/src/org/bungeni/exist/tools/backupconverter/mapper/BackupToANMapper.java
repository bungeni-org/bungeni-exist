package org.bungeni.exist.tools.backupconverter.mapper;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;
import org.bungeni.exist.tools.backupconverter.backup.reader.BackupReader;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class BackupToANMapper implements Mapper
{
    private final static Pattern backupANFilenamePattern = Pattern.compile("(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])(_[0-9]+)?(_[a-z]{3})((@first)|(@(19|20)[0-9]{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])))?\\.[a-z0-9]+");
    private final static Matcher backupANFilenameMatcher = backupANFilenamePattern.matcher("");

    public final static String DATA_PATH = "db/bungeni/data/";

    @Override
    public boolean shouldMap(Item item)
    {
        return item.getPath().startsWith(DATA_PATH);
    }

    @Override
    public String mapPath(Collection col)
    {
        String path = col.getPath();
        
        return path.substring(path.indexOf(DATA_PATH) + DATA_PATH.length());
    }

    @Override
    public String mapPath(Resource resource)
    {
        String path = resource.getPath();

        //set to the AN root
        path = path.substring(path.indexOf(DATA_PATH) + DATA_PATH.length());

        //get the filename part
        String filename = path.substring(path.lastIndexOf(BackupReader.PATH_SEPARATOR) + 1);

        backupANFilenameMatcher.reset(filename);
        if(!backupANFilenameMatcher.matches())
            return path;

        //remove the filename part from the path
        path = path.substring(0, path.lastIndexOf(BackupReader.PATH_SEPARATOR));

        //get the month and day from the filename
        String mmdd = filename.substring(0, 5);
        path += '-' + mmdd + BackupReader.PATH_SEPARATOR;

        //remove the month and day from the filename
        filename = filename.substring(5);

        //is there a number component
        if(filename.startsWith("_"))
        {
            //get the number from the filename
            String number = filename.substring(1, filename.lastIndexOf('_'));
            path += number + BackupReader.PATH_SEPARATOR;

            //remove the number from the filename
            filename = filename.substring(filename.lastIndexOf('_'));
        }

        //remainder of the filename ignoring the leading _ is the new filename appended to the path
        //get the language from the filename
        path += filename.substring(1);

        return path;
    }
}
