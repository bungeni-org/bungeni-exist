package org.bungeni.exist.tools.backupconverter.backup.reader;


import org.bungeni.exist.tools.backupconverter.backup.Item;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * Abstractions for reading from a Backup
 * 
 * This class and package make heavy use of lazy
 * evaluation for reading from the underlying files
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public abstract class BackupReader implements Iterator<Item>
{
    public final static String PATH_SEPARATOR = "/";
    
    protected final File backupSrc;
    protected List<Item> backupItems = null;
    private Iterator<Item> backupItemsIterator = null;;

    /**
     * @param backupSrc The backup source that we are reading
     */
    protected BackupReader(File backupSrc)
    {
        this.backupSrc = backupSrc;
    }

    /**
     * Gets the Items contained in the Backup
     *
     * @return List of Items from the Backup
     *
     * @thows IOException if an error reading the backup occurs
     */
    protected abstract List<Item> getBackupItems() throws IOException;

    /**
     * Gets an Iterator for moving over the backup items
     *
     * @return Iterator
     */
    private Iterator<Item> getBackupItemsIterator() throws IOException
    {
        if(backupItemsIterator == null)
            backupItemsIterator = getBackupItems().iterator();

        return backupItemsIterator;
    }

    /**
     * Next Item for the Iterator
     *
     * @return The next Item
     *
     * @see java.util.Iterator#next()
     */
    @Override
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

    /**
     * hasNext for the Iterator
     *
     * @return true if there is a next Item, false otherwise
     *
     * @see java.util.Iterator#hasNext()
     */
    @Override
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

    /**
     * @see java.util.Iterator#remove()
     */
    @Override
    public void remove()
    {
        throw new UnsupportedOperationException("It is not possible to remove items from a backup");
    }

    /**
     * Closes the Backup Reader and any underlying
     * resources for reading the backup
     *
     * @throws IOException If an exception occurs releasing resources
     */
    public abstract void close() throws IOException;
}
