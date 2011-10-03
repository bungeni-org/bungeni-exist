package org.bungeni.exist.tools.backupconverter.backup.reader;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Contents;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.ItemPathComparator;
import org.bungeni.exist.tools.backupconverter.backup.Resource;

import org.exist.backup.BackupDescriptor;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * BackupReader for reading an eXist Backup from the file system
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class FileSystemBackupReader extends BackupReader
{
    private final String backupFolderPath;

    /**
     * @param backupFolder The backup folder that we are reading
     */
    public FileSystemBackupReader(File backupFolder)
    {
        super(backupFolder);
        backupFolderPath = backupFolder.getAbsolutePath();
    }

    
    @Override
    protected List<Item> getBackupItems() throws IOException
    {
        if(this.backupItems == null)
        {
            //load the items from the backup
            this.backupItems = loadItemsRecursive(backupSrc, new ArrayList<Item>());

            //sort the items into A-Z path order
            Collections.sort(backupItems, new ItemPathComparator());
        }

        return this.backupItems;
    }

    /**
     * Recursivley moves through the backup folder and loads the items from the backup
     *
     * @param f The folder to load the items from
     * @param items The cumulatively loaded items
     *
     * @return List of Items loaded from the backup
     */
    private List<Item> loadItemsRecursive(File f, List<Item> items) throws IOException
    {
        String path = getPathRespectingBackupFolder(f);

        if(f.isDirectory())
        {
            if(path.length() != 0)
            {
                //collection
                items.add(new Collection(path));
            }

            //recurse
            String children[] = f.list();
            for(String child : children)
            {
                loadItemsRecursive(new File(f, child), items);
            }
        }
        else
        {
            if(path.endsWith(BackupDescriptor.COLLECTION_DESCRIPTOR))
            {
                //contents
                items.add(new Contents(path, new FileInputStream(f)));
            }
            else
            {
                //resource
                items.add(new Resource(path, new FileInputStream(f)));
            }
        }

        return items;
    }

    /**
     * Gets the path of file backupFile relative to the backup folder
     *
     * @param backupFile A file from the Backup
     *
     * @return The absolute path of backupFile with respect to the backup folder
     */
    private String getPathRespectingBackupFolder(File backupFile)
    {
        String path = backupFile.getPath();
        path = path.substring(path.indexOf(backupFolderPath) + backupFolderPath.length());

        if(path.startsWith(PATH_SEPARATOR))
            path = path.substring(1);

        return path;
    }

    @Override
    public void close() throws IOException
    {
    }
}
