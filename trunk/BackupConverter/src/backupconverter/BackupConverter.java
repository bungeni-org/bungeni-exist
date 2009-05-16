package backupconverter;


import java.io.File;
import java.io.PrintStream;
import java.io.IOException;

import org.exist.backup.BackupDirectory;
import org.exist.backup.BackupDescriptor;

import backupconverter.backup.Collection;
import backupconverter.backup.Item;
import backupconverter.backup.Resource;
import backupconverter.backup.reader.FolderBackupReader;
import backupconverter.backup.reader.ZipBackupReader;
import backupconverter.backup.reader.BackupReader;


/**
 * Tool for converting an eXist backup to an
 * Akoma Ntoso Layout mirroring the database
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class BackupConverter
{
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException
    {
        if(args.length != 2)
        {
            printUseage(System.out);
            return;
        }


        String backupSrc = args[0];
        String dst = args[1];

        BackupConverter backupConverter = new BackupConverter();
        backupConverter.convert(new File(backupSrc), new File(dst));
    }

    private String ZIPPED_BACKUP_SUFFIX = ".zip";

    private static void printUseage(PrintStream out)
    {
        out.println("");
        out.println("BackupConverter <eXist backup> <destination>");
        out.println("");
        out.println("eXist backup:\t The filesystem location of an eXist database backup. This may be either a full folder backup or a zip file backup.");
        out.println("");
        out.println("destination: \t This filesystem destination for the Akoma Ntoso layout to be written to.");
        out.println("");
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

        if(backupSrc.getName().startsWith(BackupDirectory.PREFIX_INC_BACKUP_FILE))
        {
            //incremental backup
        }
        else
        {
           //full backup
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
