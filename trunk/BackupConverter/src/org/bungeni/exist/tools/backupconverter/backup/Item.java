package org.bungeni.exist.tools.backupconverter.backup;


/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public abstract class Item
{
    private String path = null;
    
    protected Item(String path)
    {
        this.path = path;
    }
    
    public String getPath()
    {
        return path;
    }
}
