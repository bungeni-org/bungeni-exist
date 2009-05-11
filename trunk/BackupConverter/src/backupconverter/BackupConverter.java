package backupconverter;


import backupconverter.backup.Collection;
import backupconverter.backup.Item;
import backupconverter.backup.Resource;
import backupconverter.backup.reader.FolderBackupReader;
import backupconverter.backup.reader.ZipBackupReader;
import backupconverter.backup.reader.BackupReader;
import java.io.File;
import java.io.IOException;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class BackupConverter
{
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws Exception
    {
        String backupSrc = args[0];
        String dst = args[1];

        BackupConverter backupConverter = new BackupConverter();
        backupConverter.convert(new File(backupSrc), new File(dst));
    }

    private String ZIPPED_BACKUP_SUFFIX = ".zip";


    public BackupConverter()
    {

    }

    public void convert(File backupSrc, File dst) throws IOException
    {
        BackupReader backupReader = null;

        if(backupSrc.getName().endsWith(ZIPPED_BACKUP_SUFFIX))
        {
            backupReader = new ZipBackupReader(backupSrc);
        }
        else
        {
            backupReader = new FolderBackupReader(backupSrc);
        }

        Mapper mapper = new BackupToANMapper();
        ANWriter writer = new ANFolderWriter(mapper, dst);

        //read the backup
        while(backupReader.hasNext())
        {
            Item item = backupReader.next();

            if(item instanceof Collection)
            {
                writer.writeCollection((Collection)item);
            }
            else if(item instanceof Resource)
            {
                writer.writeResource((Resource)item);
            }
        }

        backupReader.close();
    }
}
