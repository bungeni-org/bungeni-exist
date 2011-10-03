package org.bungeni.exist.tools.backupconverter.writer;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;

import java.io.IOException;

/**
 * Akoma Ntoso Writer
 * Responsible for writting Items to to an Akoma Ntoso destination
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public interface ANWriter
{
    /**
     * Writes a Collection
     *
     * @param collection The Collection to write
     */
    public void writeCollection(Collection collection) throws IOException;

    /**
     * Writes a Resource
     *
     * @param resource The Resource to write
     */
    public void writeResource(Resource resource) throws IOException;

    /**
     * Removes a Collection
     *
     * @param collection The Collection to remove
     */
    public void removeCollection(Item collection) throws IOException;

    /**
     * Removes a Resource
     *
     * @param resource The Resource to remove
     */
    public void removeResource(Item resource) throws IOException;
}
