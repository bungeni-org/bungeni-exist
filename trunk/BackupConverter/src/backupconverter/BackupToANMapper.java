package backupconverter;


import backupconverter.backup.Collection;
import backupconverter.backup.Item;
import backupconverter.backup.Resource;
import backupconverter.backup.reader.BackupReader;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class BackupToANMapper implements Mapper
{
    private final static String DATA_PATH = "db/bungeni/data/";

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
    public String mapPath(Resource res)
    {
        String path = res.getPath();

        //set to the AN root
        path = path.substring(path.indexOf(DATA_PATH) + DATA_PATH.length());

        //get the filename part
        String filename = path.substring(path.lastIndexOf(BackupReader.PATH_SEPARATOR) + 1);

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
