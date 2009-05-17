package backupconverter;


import java.io.File;
import java.io.PrintStream;
import java.io.IOException;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.exist.backup.BackupDescriptor;
import org.exist.backup.FileSystemBackupDescriptor;
import org.exist.backup.ZipArchiveBackupDescriptor;

import backupconverter.backup.Collection;
import backupconverter.backup.Contents;
import backupconverter.backup.Contents.ContentsEntry;
import backupconverter.backup.Contents.ContentsResourceEntry;
import backupconverter.backup.Contents.ContentsSubCollectionEntry;
import backupconverter.backup.Item;
import backupconverter.backup.Resource;
import backupconverter.backup.reader.FileSystemBackupReader;
import backupconverter.backup.reader.ZipArchiveBackupReader;
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

    private String getPreviousBackupSrc(BackupDescriptor bdBackupSrc) throws IOException
    {
        Properties backupProperties = bdBackupSrc.getProperties();
        
        if(backupProperties != null)
        {
            String pIncremental = bdBackupSrc.getProperties().getProperty(BackupDescriptor.INCREMENTAL_PROP_NAME);
            String pPrevious = bdBackupSrc.getProperties().getProperty(BackupDescriptor.PREVIOUS_PROP_NAME);

            if(pIncremental.equalsIgnoreCase("yes") && pPrevious != null)
            {
                return pPrevious;
            }
        }

        return null;
    }

    public void convert(File backupSrc, File dst) throws IOException
    {
        BackupReader brBackupSrc = null;
        BackupReader brPreviousSrc = null;

        BackupDescriptor bdBackupSrc = null;
        if(backupSrc.isDirectory())
        {
            brBackupSrc = new FileSystemBackupReader(backupSrc);
            bdBackupSrc = new FileSystemBackupDescriptor(new File(backupSrc, "db/" + BackupDescriptor.COLLECTION_DESCRIPTOR));

            String prevBackup = getPreviousBackupSrc(bdBackupSrc);
            if(prevBackup != null && prevBackup.length() > 0)
            {
                File prevBackupSrc = new File(backupSrc, prevBackup);
                brPreviousSrc = new FileSystemBackupReader(prevBackupSrc);
            }
        }
        else if(backupSrc.getName().endsWith(ZIPPED_BACKUP_SUFFIX))
        {
            brBackupSrc = new ZipArchiveBackupReader(backupSrc);
            bdBackupSrc = new ZipArchiveBackupDescriptor(backupSrc);

            String prevBackup = getPreviousBackupSrc(bdBackupSrc);
            if(prevBackup != null && prevBackup.length() > 0)
            {
                File prevBackupSrc = new File(backupSrc.getParentFile(), prevBackup);
                brPreviousSrc = new ZipArchiveBackupReader(prevBackupSrc);
            }
        }
        else
        {
            throw new IOException("Unknown backup type");
        }

        

        
        Mapper mapper = new BackupToANMapper();

        ANWriter writer = new ANFolderWriter(mapper, dst);

        //load the contents of the previous backup
        Map<String, Contents> previousContents = new HashMap<String, Contents>();
        if(brPreviousSrc != null)
        {
            while(brPreviousSrc.hasNext())
            {
                 Item item = brPreviousSrc.next();
                 if(item instanceof Contents)
                 {
                     previousContents.put(item.getPath(), (Contents)item);
                 }
            }
        }


        //read the backup
        while(brBackupSrc.hasNext())
        {
            Item item = brBackupSrc.next();

            if(item instanceof Collection)
            {
                writer.writeCollection((Collection)item);
            }
            else if(item instanceof Resource)
            {
                writer.writeResource((Resource)item);
            }
            else if(item instanceof Contents)
            {
                if(brPreviousSrc != null)
                {
                    Contents contents = ((Contents)item);
                    Contents prevContents = previousContents.get(contents.getPath());

                    List<ContentsEntry> contentsEntries = contents.getEntries();

                    //look for entries in prevContents that dont exist in contents - these entries have been deleted.
                    for(ContentsEntry prevContentsEntry : prevContents.getEntries())
                    {
                        if(!contentsEntries.contains(prevContentsEntry))
                        {
                            //entry has been deleted
                            if(prevContentsEntry instanceof ContentsSubCollectionEntry)
                            {
                                writer.removeCollection(prevContentsEntry);
                            }
                            else if(prevContentsEntry instanceof ContentsResourceEntry)
                            {
                                writer.removeResource(prevContentsEntry);
                            }
                        }
                    }
                }
            }
        }

        brBackupSrc.close();
    }
}
