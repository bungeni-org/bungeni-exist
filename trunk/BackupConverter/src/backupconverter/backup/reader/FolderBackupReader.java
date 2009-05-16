package backupconverter.backup.reader;


import backupconverter.backup.Collection;
import backupconverter.backup.Contents;
import backupconverter.backup.Item;
import backupconverter.backup.ItemPathComparator;
import backupconverter.backup.Resource;
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
public class FolderBackupReader extends BackupReader
{
    private final String backupSrcPath;

    public FolderBackupReader(File backupSrc)
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
            if(path.endsWith(Contents.CONTENTS_FILE))
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
