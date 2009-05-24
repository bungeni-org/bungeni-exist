package org.bungeni.exist.tools.backupconverter.mapper;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;

/**
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public interface Mapper
{
    public boolean shouldMap(Item item);

    public String mapPath(Collection col);

    public String mapPath(Resource res);


}
