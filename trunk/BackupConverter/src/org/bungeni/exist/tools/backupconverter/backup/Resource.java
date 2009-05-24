package org.bungeni.exist.tools.backupconverter.backup;


import java.io.InputStream;

/**
 * Represents a Resource in the Backup
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public class Resource extends Item
{
    private final InputStream inputStream;

    /**
     * @param path The Path of the Resource
     * @param inputStream The input stream for reading the Resource
     */
    public Resource(String path, InputStream inputStream)
    {
        super(path);
        this.inputStream = inputStream;
    }

    /**
     * Get the InputStream for reading the resource
     *
     * @return The InputStream for reading the resource
     */
    public InputStream getInputStream()
    {
        return this.inputStream;
    }
}
