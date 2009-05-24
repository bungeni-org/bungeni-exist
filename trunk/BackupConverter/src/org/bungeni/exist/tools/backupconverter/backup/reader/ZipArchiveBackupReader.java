package org.bungeni.exist.tools.backupconverter.backup.reader;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Contents;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.ItemPathComparator;
import org.bungeni.exist.tools.backupconverter.backup.Resource;

import org.exist.backup.BackupDescriptor;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * BackupReader for reading an eXist Backup from a Zip file
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class ZipArchiveBackupReader extends BackupReader
{
    private ZipFile zipFile = null;
    private Enumeration<? extends ZipEntry> zipFileEntries = null;

   /**
     * @param backupZip The backup zip file that we are reading
     */
    public ZipArchiveBackupReader(File backupZip)
    {
        super(backupZip);
        
    }

    @Override
    protected List<Item> getBackupItems() throws IOException
    {
        if(this.backupItems == null)
        {
            this.backupItems = new ArrayList<Item>();

            Enumeration<? extends ZipEntry> entries = getZipFileEntries();
            while(entries.hasMoreElements())
            {
                ZipEntry ze = entries.nextElement();
                String path = ze.getName();

                if(path.endsWith(BackupDescriptor.COLLECTION_DESCRIPTOR))
                {
                    String collectionPath = path.substring(0, path.lastIndexOf(BackupReader.PATH_SEPARATOR));
                    if(!isKnownCollection(collectionPath))
                    {
                        //collection from contents (some zip files dont have the collections in them, so we infer them from the contents)
                        this.backupItems.add(new Collection(collectionPath));
                    }

                    //contents
                    this.backupItems.add(new Contents(path, zipFile.getInputStream(ze)));
                }
                else if(ze.isDirectory())
                {
                    String collectionPath = path;
                    if(collectionPath.endsWith(BackupReader.PATH_SEPARATOR))
                        collectionPath = collectionPath.substring(0, collectionPath.length()-1);

                    if(!isKnownCollection(collectionPath))
                    {
                        //collection
                        this.backupItems.add(new Collection(collectionPath));
                    }
                }
                else
                {
                    //resource
                    this.backupItems.add(new Resource(path, zipFile.getInputStream(ze)));
                }
            }

            //sort the items into A-Z path order
            Collections.sort(backupItems, new ItemPathComparator());
        }

        return this.backupItems;
    }

    /**
     * Get the Zip file of the Backup
     *
     * @return The Zip file
     */
    private ZipFile getZipFile() throws IOException
    {
        if(this.zipFile == null)
            this.zipFile = new ZipFile(backupSrc);

        return this.zipFile;
    }

    /**
     * Get the Entries from the Zip file Backup
     *
     * @return Enumeration of ZipFile entries
     */
    private Enumeration<? extends ZipEntry> getZipFileEntries() throws IOException
    {
        if(this.zipFileEntries == null)
            this.zipFileEntries = getZipFile().entries();

        return this.zipFileEntries;
    }

    /**
     * Determines if a Collection is already known
     *
     * @param collectionPath Path of the Collection
     *
     * @return true if the collectionPath is known, false otherwise
     */
    private boolean isKnownCollection(String collectionPath)
    {
        for(Item item : backupItems)
        {
            if(item instanceof Collection && item.getPath().equals(collectionPath))
                return true;
        }

        return false;
    }

    /**
     * Closes the Zip file
     */
    @Override
    public void close() throws IOException
    {
        zipFile.close();
    }

   
}
