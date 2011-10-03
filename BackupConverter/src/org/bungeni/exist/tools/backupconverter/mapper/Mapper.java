package org.bungeni.exist.tools.backupconverter.mapper;


import org.bungeni.exist.tools.backupconverter.backup.Collection;
import org.bungeni.exist.tools.backupconverter.backup.Item;
import org.bungeni.exist.tools.backupconverter.backup.Resource;

/**
 * Maps Paths from BackupReader paths to destination paths suitable for the Writer
 *
 * @author Adam Retter <adam.retter@googlemail.com>
 * @version 1.0
 */
public interface Mapper
{
    /**
     * Should an Item be mapped by the Writer
     *
     * @param item
     *
     * @return true if the path of the Item should be mapped, false otherwise
     */
    public boolean shouldMap(Item item);

    /**
     * Maps the path of a Collection
     *
     * @param col Collection whoose path is to be mapped
     *
     * @return The mapped path of the Collection
     */
    public String mapPath(Collection collection);

    /**
     * Maps the path of a Resource
     *
     * @param res Resource whoose path is to be mapped
     *
     * @return The mapped path of the Resource
     */
    public String mapPath(Resource resource);
}
