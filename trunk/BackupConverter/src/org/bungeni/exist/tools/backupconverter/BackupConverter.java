package org.bungeni.exist.tools.backupconverter;


import org.bungeni.exist.tools.backupconverter.mapper.BackupToANMapper;
import org.bungeni.exist.tools.backupconverter.mapper.Mapper;
import org.bungeni.exist.tools.backupconverter.writer.ANFolderWriter;
import org.bungeni.exist.tools.backupconverter.writer.ANWriter;
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

import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Contents;
import org.bungeni.exist.tools.backupconverter.backup.Contents.ContentsEntry;
import org.bungeni.exist.tools.backupconverter.backup.Contents.ContentsResourceEntry;
import org.bungeni.exist.tools.backupconverter.backup.Contents.ContentsSubCollectionEntry;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;
import org.bungeni.exist.tools.backupconverter.backup.reader.FileSystemBackupReader;
import org.bungeni.exist.tools.backupconverter.backup.reader.ZipArchiveBackupReader;
import org.bungeni.exist.tools.backupconverter.backup.reader.BackupReader;


/**
 * Tool for converting an eXist backup to an
 * Akoma Ntoso Layout mirroring the database.
 *
 * Supports both full backups and
 * incremental backups.
 *
 * Backups may be provided as either a zip file backup
 * or folder structured backup.
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class BackupConverter
{
    private String ZIPPED_BACKUP_SUFFIX = ".zip";


    /**
     * Command line invocation entry point
     *
     * @param args the command line arguments
     */
    public static void main(String[] args)
    {
        //check for the two required arguments
        if(args.length != 2)
        {
            printUseage(System.out);
            return;
        }

        String backupSrc = args[0];
        String dst = args[1];

        BackupConverter backupConverter = new BackupConverter();

        try
        {
            backupConverter.convert(new File(backupSrc), new File(dst));
        }
        catch(IOException ioe)
        {
            System.err.println("An error occured whilst processing the backup: " + ioe.getMessage());
            ioe.printStackTrace();
            System.exit(-1);
        }
    }

    /**
     * Prints the command line useage instructions
     *
     * @param out The print stream to print the useage instructions to
     */
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

    /**
     * Converts an eXist backup of the Akoma Ntoso database to
     * a filesystem layout of the Akoma Ntoso standard
     *
     * @param backupSrc The backup source file/folder of the eXist backup
     * @param dst The destination for the filesystem Akoma Ntoso latout
     */
    public void convert(File backupSrc, File dst) throws IOException
    {
        BackupReader brBackupSrc = null;
        BackupDescriptor bdBackupSrc = null;
        BackupReader brPreviousSrc = null;


        //load the backup and the last previous backup if this is an incremental backup
        if(backupSrc.isDirectory())
        {
            //load from directory backup
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
            //load from zip backup
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

        
        //if its not an incremental backup and the mirror destination exists then overwite it
        if(brPreviousSrc == null)
        {
            cleanDestination(dst);
        }

        //load the contents of the previous backup
        Map<String, Contents> previousContents = getContents(brPreviousSrc);


        Mapper mapper = new BackupToANMapper();
        ANWriter writer = new ANFolderWriter(mapper, dst);
        
        //read the backup and convert each item
        while(brBackupSrc.hasNext())
        {
            Item item = brBackupSrc.next();

            convertItem(item, previousContents, writer);
        }

        brBackupSrc.close();
    }

    /**
     * Converts a backup Item
     *
     * @param item The item to convert
     * @param previousContents The contents of the previous incremental backup (if any)
     * @param writer The writer for writting to the destination
     */
    private void convertItem(Item item, Map<String, Contents> previousContents, ANWriter writer) throws IOException
    {
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
            if(previousContents != null && previousContents.size() > 0)
            {
                Contents contents = ((Contents)item);
                Contents prevContents = previousContents.get(contents.getPath());

                if(prevContents != null)    //may be a new contents entirely e.g. new collection, therefore there wont be any old contents
                {
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
    }


    /**
     * Cleans the destination folder
     *
     * @param dst The Destination folder
     */
    private void cleanDestination(File dst)
    {
        if(dst.exists())
        {
            FileUtil.recursiveDelete(dst);
            dst.mkdir();
        }
    }

    /**
     * Gets the contents entries for a backup
     *
     * @param brSrc A backup reader for reading the contents files from the backup
     *
     * @return Map of paths and contents entries from the backup
     */
    private Map<String, Contents> getContents(BackupReader br)
    {
        Map<String, Contents> contents = new HashMap<String, Contents>();

        if(br != null)
        {
            while(br.hasNext())
            {
                 Item item = br.next();
                 if(item instanceof Contents)
                 {
                     contents.put(item.getPath(), (Contents)item);
                 }
            }
        }

        return contents;
    }

    /**
     * Gets the filename of the previous backup file for an incremental backup
     *
     * @param bdBackupSrc The backup descriptor of the incremental backup
     *
     * @return The filename of the previous backup or null
     */
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
}
