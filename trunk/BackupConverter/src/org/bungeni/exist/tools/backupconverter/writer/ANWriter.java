package org.bungeni.exist.tools.backupconverter.writer;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;

import java.io.IOException;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public interface ANWriter
{


    public void writeCollection(Collection collection) throws IOException;

    public void writeResource(Resource resource) throws IOException;

    public void removeCollection(Item resource) throws IOException;

    public void removeResource(Item resource) throws IOException;
}
