package backupconverter.backup.reader;


import backupconverter.backup.Item;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public abstract class BackupReader implements Iterator<Item>
{
    public final static String PATH_SEPARATOR = "/";
    
    protected List<Item> backupItems = null;
    protected File backupSrc = null;
    private Iterator<Item> backupItemsIterator = null;;


    public BackupReader(File backupSrc)
    {
        this.backupSrc = backupSrc;
    }

    

    protected abstract List<Item> getBackupItems() throws IOException;

    protected Iterator<Item> getBackupItemsIterator() throws IOException
    {
        if(backupItemsIterator == null)
            backupItemsIterator = getBackupItems().iterator();

        return backupItemsIterator;
    }

    public Item next() throws NoSuchElementException
    {
        try
        {
            return getBackupItemsIterator().next();
        }
        catch(IOException ioe)
        {
            throw new NoSuchElementException(ioe.getMessage());
        }
    }

    public boolean hasNext()
    {
        try
        {
            return getBackupItemsIterator().hasNext();
        }
        catch(IOException ioe)
        {
            return false;
        }
    }

    public void remove()
    {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public abstract void close() throws IOException;

}
