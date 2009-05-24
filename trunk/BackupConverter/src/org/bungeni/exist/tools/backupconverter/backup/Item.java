package org.bungeni.exist.tools.backupconverter.backup;


/**
 * Represents an Item in the Backup
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public abstract class Item
{
    private String path = null;

    /**
     * @param path Path of the item
     */
    protected Item(String path)
    {
        this.path = path;
    }

    /**
     * Get the Path of the item
     *
     * @return the Path of the item
     */
    public String getPath()
    {
        return path;
    }
}
