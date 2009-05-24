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
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class FileSystemBackupReader extends BackupReader
{
    private final String backupSrcPath;

    public FileSystemBackupReader(File backupSrc)
    {
        super(backupSrc);
        backupSrcPath = backupSrc.getAbsolutePath();
    }

    private List<Item> loadItemsRecursive(File f, List<Item> items) throws IOException
    {
        String path = getPathRelativeToBackupSrc(f);

        if(f.isDirectory())
        {
            if(path.length() != 0)
                items.add(new Collection(path));

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
                items.add(new Contents(path, new FileInputStream(f)));
            }
            else
            {
                items.add(new Resource(path, new FileInputStream(f)));
            }
        }

        return items;
    }

    private String getPathRelativeToBackupSrc(File f)
    {
        String path = f.getPath();
        path = path.substring(path.indexOf(backupSrcPath) + backupSrcPath.length());

        if(path.startsWith(PATH_SEPARATOR))
            path = path.substring(1);
        
        return path;
    }

    @Override
    protected List<Item> getBackupItems() throws IOException
    {
        if(this.backupItems == null)
        {
            this.backupItems = loadItemsRecursive(backupSrc, new ArrayList<Item>());
            Collections.sort(backupItems, new ItemPathComparator());
        }

        return this.backupItems;
    }

    @Override
    public void close() throws IOException
    {
    }
}
